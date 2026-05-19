import { fileURLToPath, URL } from 'node:url'
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      '@freewind/FloatLabel': fileURLToPath(new URL('./node_modules/freewind-antd-components/src/components/FloatLabel/FloatLabel.tsx', import.meta.url)),
      '@freewind/JsonPreviewer': fileURLToPath(new URL('./node_modules/freewind-antd-components/src/components/JsonPreviewer/JsonPreviewer.tsx', import.meta.url)),
    },
  },
  build: {
    emptyOutDir: true,
    outDir: '../Sources/FreewindSwiftUIDebugServer/WebConsoleDist',
  },
})
