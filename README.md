# Pomodoro App

番茄钟 H5（Vue 3 + Vite + TypeScript + Pinia）。

- `h5/`：前端工程，可 `npm install && npm run dev` 本地预览。
- `assets/`：白噪音原始素材（与 `h5/public/audio/` 中的 ogg 对应）。

## 部署到 GitHub Pages（自动）

仓库已配置 `.github/workflows/deploy.yml`，push 到 `main` 即自动构建并发布：

1. 在 GitHub 新建仓库（仓库名决定访问路径 `https://<用户名>.github.io/<仓库名>/`）。
2. 本地初始化并提交，例如：
   ```bash
   git init
   git add .
   git commit -m "init"
   git branch -M main
   git remote add origin git@github.com:<用户名>/<仓库名>.git
   git push -u origin main
   ```
3. 仓库 **Settings → Pages → Build and deployment → Source 选择 "GitHub Actions"**。
4. 等 Actions 跑完，访问上面的 Pages 地址即可。

> 说明：流水线用 `npm run build -- --base=/<仓库名>/` 注入 base，
> 白噪音音频走 `import.meta.env.BASE_URL + 'audio/...'`，因此在子路径下也能正常加载。
>
> 注意：`.ogg` 在 Safari / iOS 原生不支持，iPhone 上需补充 mp3/m4a 双格式。
