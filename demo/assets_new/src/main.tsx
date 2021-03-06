// Needed, because automatic injection via HTML manipulation is not possible.
import 'vite/dynamic-import-polyfill'

// imported from phx
import './vendor/phx-app.css'
import "./vendor/phx-app.js"

import { render, h } from 'preact'
import { App } from './app'
import './index.css'

render(<App />, document.getElementById('app')!)
