new Vue({
  el: "#app",
  data: {
    queue: [],
  },
  methods: {
    getData () {
      fetch('/', {
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
      switch (choice) {
        case 'nope':
          break;
        case 'like':
          break;
        case 'super':
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
