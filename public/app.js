new Vue({
  el: "#app",
  data: {
    queue: [],
    measurementableFlg: false,
  },
  methods: {
    getData () {
      let url = ''
      if (this.measurementableFlg) {
        url = '/?class_name=Marketing::Messageable::Measurementable&method_name=measurement_for_show(unit:, dates:, custom_event: nil)'
      } else {
        url = '/'
      }
      this.measurementableFlg = false
      fetch(url, {
        method: 'GET',
        headers: {
          'Content-Type': 'application/json',
        }
      })
      .then(res => res.json())
      .then(json => {
        // TODO: Fix queueing
        // queuingがうまくいかないので、毎回1個分だけ取りに行っている
        this.queue = [{ key: json.defined_method.class_name, method: json.defined_method, }];
      })
    },
    decide (choice) {
      this.$refs.tinder.decide(choice)
    },
    submit (choice) {
      switch (choice.type) {
        case 'nope':
          break;
        case 'like':
          break;
        case 'super':
          this.measurementableFlg = true;
          break;
      }
      if (this.queue.length < 2) {
        this.getData()
      }
    }
  },
  created () {
    this.getData()
  },
})
