# Web Deployment Guide (Netlify & Vercel)

This application is ready to be built for the web.

## Before you build

Ensure that you have generated the Firebase configuration for Web:
```bash
flutterfire configure
```
Make sure you select the `web` option when prompted.

## Building the Web App

To create the production build for your Flutter Web application, run:

```bash
flutter build web
```

Or, if you prefer the standard web renderer (CanvasKit):
```bash
flutter build web --web-renderer canvaskit
```

Once the build finishes, all the files you need to deploy will be located in the `build/web/` directory.

---

## Deploying to Netlify

Netlify is one of the easiest ways to host a Flutter web app. You can deploy either manually via Drag & Drop or using the Netlify CLI.

### Option 1: Drag & Drop (Easiest)
1. Go to [Netlify Drop](https://app.netlify.com/drop).
2. Drag and drop your **entire** `build/web/` folder onto the page.
3. Your site will immediately go live with a random URL. You can change this in the Site Settings.

### Option 2: Using Netlify CLI
1. Install Netlify CLI: `npm install -g netlify-cli`
2. Run the deployment command from your project root:
   ```bash
   netlify deploy --dir=build/web --prod
   ```

---

## Deploying to Vercel

Vercel is another great option, especially if you have a GitHub repository connected, but you can also deploy manually via CLI.

### Option 1: Vercel CLI
1. Install Vercel CLI: `npm i -g vercel`
2. From the root of your Flutter project, run:
   ```bash
   vercel
   ```
3. When prompted:
   - "Set up and deploy": `Y`
   - Select your scope.
   - Link to existing project: `N`
   - Project name: (Keep default or name it)
   - "In which directory is your code located?": Enter `./build/web`
4. The deployment will proceed and provide you with a production URL.

### Option 2: GitHub Integration
1. Push your Flutter project to a GitHub repository.
2. Go to the [Vercel Dashboard](https://vercel.com/dashboard) and click "Add New... -> Project".
3. Import your GitHub repository.
4. In the "Build and Output Settings":
   - Framework Preset: `Other`
   - Build Command: `flutter build web`
   - Output Directory: `build/web`
5. Click "Deploy".
