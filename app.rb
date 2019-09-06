require 'sinatra'
require 'sinatra/reloader'
require 'pry'

before do
  raise "SEARCH_PATH環境変数が指定されていません"  unless ENV['SEARCH_PATH']
end

get '/' do
  @defined_method = defined_methods.sample
  erb :index
end

get '/refresh' do
  refresh_defined_methods
  redirect '/'
end

helpers do

  def defined_methods
    @@defined_methods ||= create_defined_methods
  end

  def refresh_defined_methods
    @@defined_methods = nil
  end

  def create_defined_methods
    defined_methods = []

    Dir.glob("**/*.rb", base: repo) do |path|
      File.open(full_path(path), "r") do |file|
        defined_methods.concat(DefinedMethodExtractor.new(file).run)
      end
    end
    defined_methods
  end

  def repo
    ENV['SEARCH_PATH']
  end

  def full_path(file)
    "#{repo}/#{file}"
  end

  class DefinedMethodExtractor

    DefindMethod = Struct.new(
      :class_name,
      :class_type,
      :method_name,
      :path,
      :method_body_lines,
    )
  
    attr_reader :file, :class_names, :class_type, :current_class_indent, :method_name, :current_method_indent, :defined_methods, :in_method, :method_body_lines

    def initialize(file)
      @file = file
      @defined_methods = []
      @class_names = []
      @class_type = ""
      @method_name = ""
      @current_class_indent = ""
      @current_method_indent = ""
      @in_method = false
      @method_body_lines = []
    end

    def run
      @file.each_line do |line|
        match_with_class_define(line)

        match_with_end_of_class_deline(line)

        match_with_method_define(line)

        save_method_body_lines_if_needed(line)

        match_with_end_of_method_define(line)
      end

      @defined_methods
    end

    private

    def match_with_class_define(line)
      if h = line.match(/^(?<current_class_indent>\s*)(?<class_type>class|module)\s(?<class_name>.+)(?<!\send)$/)
        @current_class_indent = h[:current_class_indent]
        @class_type = h[:class_type]
        @class_names.push(h[:class_name])
      end
    end

    def match_with_end_of_class_deline(line)
      if line.match(/^#{@current_class_indent}(end)$/)
        @class_names.delete_at(-1)
        @current_class_indent.slice!(0..1)
      end
    end

    def match_with_method_define(line)
      if h = line.match(/^(?<current_method_indent>\s*)def\s(?<method_name>.+)/)
        @current_method_indent = h[:current_method_indent]
        @method_name = h[:method_name]
        @in_method = true
      end
    end

    def match_with_end_of_method_define(line)
      if @in_method && line.match(/^#{@current_method_indent}(end)$/)
        @current_method_indent = ""
        @defined_methods.push(
          DefindMethod.new.tap do |d|
            d.class_name = resolve_class_name
            d.class_type = @class_type
            d.method_name = add_singleton_prefix_if_needed
            d.path = @file.path
            d.method_body_lines = @method_body_lines
          end
        )
        @in_method = false
        @method_body_lines = []
      end
    end

    def save_method_body_lines_if_needed(line)
      if @in_method
        @method_body_lines.push(line)
      end
    end

    def resolve_class_name
      return "no class" if @class_names.empty?

      @class_names.each_with_index.inject("") do |full_name, (name, idx)|
        if idx == 0
          full_name = name
        else
          if name == "<< self"
            full_name
          else
            full_name = "#{reject_superclass_string(full_name)}::#{name}"
          end
        end
      end
    end

    def reject_superclass_string(name)
      if h = name.match(/^(?<name>.+)\s<\s(.+)$/)
        h[:name]
      else
        name
      end
    end

    def add_singleton_prefix_if_needed
      if need_singleton_prefix?
        "self.#{@method_name}"
      else
        @method_name
      end
    end

    def need_singleton_prefix?
      @class_names.last == "<< self"
    end
  end
end
