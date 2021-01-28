import preactRefresh from '@prefresh/vite'
import { defineConfig } from 'vite'

// https://vitejs.dev/config/
export default defineConfig({
  esbuild: {
    jsxFactory: 'h',
    jsxFragment: 'Fragment'
  },
  build: {
    manifest: true,
    target: "es2018",
    outDir: "../priv/static", // phoenix expects our files here
    emptyOutDir: true, // cleanup previous builds
    polyfillDynamicImport: true,
    sourcemap: true, // we want to debug our code in production
    rollupOptions: {
      // overwrite default .html entry
      input: {
        main: "src/main.tsx",
      }
    },
  },
  plugins: [preactRefresh()]
})
