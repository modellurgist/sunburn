// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "topbar"
// import {getHooks, initializeVueApp} from "live_vue"
import {getHooks} from "live_vue"
import components from "../vue"
import "../css/app.css"
import "vite/modulepreload-polyfill"

// PrimeVue setup and components
// import 'primevue/resources/themes/tailwind-light/theme.css'
import PrimeVue from "primevue/config"
import Tree from 'primevue/tree';
// import TreeTable from 'primevue/treetable';
// import Column from 'primevue/column';

import {h} from "vue"

const initializeVueApp = ({createApp, component, props, slots, plugin, el}) => {
  const renderFn = () => h(component, props, slots)
  const app = createApp({render: renderFn})
  app.use(plugin)

  // Initialize additional plugins
  // - primevue
  const primeVueOptions = {unstyled: true}
  console.log("PrimeVue")
  console.log(PrimeVue)
  app.use(PrimeVue, primeVueOptions)

  // Register components
  // TreeTable takes array of TreeNode's as value (https://primevue.org/tree/#api.treenode)
  // - see source code for that page here: https://github.com/primefaces/primevue/blob/master/apps/showcase/pages/treetable/index.vue
  //   and here: https://github.com/primefaces/primevue/blob/master/apps/showcase/doc/treetable/BasicDoc.vue
  //   and full data here: https://github.com/primefaces/primevue/blob/master/apps/showcase/service/NodeService.js#L71
  // - might, instead, need to import explicitly in assets/vue/index.js
  // - see also https://stackoverflow.com/questions/67745052/how-can-i-render-primevue-tree-items-as-links
     
  app.component('Tree', Tree)
  // app.component('TreeTable', TreeTable)
  // app.component('Column', Column)

  console.log("app")
  console.log(app)

  app.mount(el)
  return app
}

const initializeApp = context => {
  // initializeVueApp is a default function creating and initializing LiveVue App
  //
  // Can also customize by rolling own function for this (see https://github.com/Valian/live_vue/commit/5240979d091fcbbb06aa5b128dddb545e9c67b6d#diff-b335630551682c19a781afebcf4d07bf978fb1f8ac04c6bf87428ed5106870f5R324)
  const app = initializeVueApp(context)

  return app
}

const hooks = getHooks(components, {initializeApp})

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")

let liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: {_csrf_token: csrfToken},
  hooks: hooks
})

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

