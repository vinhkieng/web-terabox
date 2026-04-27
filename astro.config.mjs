import { defineConfig } from 'astro/config';

export default defineConfig({
  output: 'static',
  build: {
    format: 'file'
  },
  // Thêm dòng này nếu muốn đường dẫn file không bắt đầu bằng dấu /
  // Nó sẽ giúp tránh lỗi đường dẫn gốc trên Hosting
  base: './', 
});