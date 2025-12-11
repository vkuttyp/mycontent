---
title: My Test content page
description: Testing around
---

# Nuxt Minimal Starter

Look at the [Nuxt documentation](https://nuxt.com/docs/getting-started/introduction) to learn more.

## Setup

Make sure to install dependencies:

````markdown
# Nuxt Minimal Starter

Look at the [Nuxt documentation](https://nuxt.com/docs/getting-started/introduction) to learn more.

## Setup

Make sure to install dependencies:

```bash
# npm
npm install

# pnpm
pnpm install

# yarn
yarn install

# bun
bun install
```

## Development Server

Start the development server on `http://localhost:3000`:

```bash
# pnpm
pnpm dev

# yarn
yarn dev

# bun
bun run dev
```

## Production

Build the application for production:

```bash
# npm
npm run build

# yarn
yarn build
```bash
# npm
# pnpm
pnpm preview

# yarn
# bun
bun run preview
```

Check out the [deployment documentation](https://nuxt.com/docs/getting-started/deployment) for more information.

````

## Project specifics

This project includes a small data/repository helper and an API plugin with built-in auth support.

**Repository factory**: `app/utils/repository.ts`

- Create typed repositories with `createRepository<T>(basePath, { throwOnError })`.
- Prefers `useUserSession().fetch` (from `nuxt-auth-utils`) when available so requests participate in the session lifecycle (cookies, refresh, etc.). Falls back to the injected `$api`, `$fetch`, or global `$fetch`.
- Convenience export: `userRepository` is pre-created as `createRepository<User>('/users', { throwOnError: false })` to preserve previous non-throwing behavior.

Basic usage:

```ts
import { userRepository, createRepository } from '~/app/utils/repository'

// convenience (non-throwing):
const users = await userRepository.getAll()

// throwing repo (explicit error handling):
const repo = createRepository<User>('/users', { throwOnError: true })
try {
    const list = await repo.getAll()
} catch (err) {
    // handle error
}
```

**API plugin & Auth**: `app/plugins/api.ts`

- The `$api` plugin sends cookies (`credentials: 'include'`) so HTTP-only refresh cookies work for authentication.
- It implements an automatic refresh flow: on 401 the plugin will POST to the configured refresh endpoint and, if successful, retry the original request once.
- It supports an optional fallback to attach an `Authorization` header from storage/cookie when enabled in runtime config.

Runtime config (set in `nuxt.config` or environment):

- `public.apiBaseUrl` — API base URL
- `public.authRefreshPath` — refresh endpoint (default: `/auth/refresh`)
- `public.tokenCookieName` — cookie name for token (default: `token`)
- `public.attachAuthHeader` — boolean to enable header fallback (default: `false`)
- `public.authHeaderName` / `public.authHeaderPrefix` — header name/prefix for fallback
- `public.authAutoLogout` — redirect to login on failed refresh (default: `true`)
- `public.authLogoutRedirect` — client redirect path after failed refresh (default: `/login`)

Notes:

- Backend must support the refresh endpoint and set HTTP-only cookies for secure operation.
- If your API is cross-origin, ensure CORS allows credentials (Access-Control-Allow-Credentials: true) and the correct origins.

If you want, I can add a short example showing how your backend should implement `/auth/refresh`.

**JWKS / RS256**: This project supports verifying RS256-signed JWTs using a remote JWKS endpoint. Configure the following environment variable on the Nuxt server (or in your runtime config):

- `JWT_JWKS_URL`: URL to the JWKS JSON (e.g. `https://auth.example.com/.well-known/jwks.json`). When set, the server proxies (`/auth/remote/login`, `/auth/remote/refresh`) will attempt to verify RS256 signatures using the keys from the JWKS. Keys are cached for a short time.

The existing `JWT_SIGNING_KEY` (HS256) behavior remains supported — the proxy will try HS256 verification first if that key is present, and then will attempt RS256/JWKS verification when `JWT_JWKS_URL` is configured.

**Example projects**: See `examples/aspnet-sample/` for a minimal ASP.NET Web API sample that implements `/auth/seed` and `/auth/refresh` using HTTP-only refresh cookies (SQLite persistence). Run it from the repo with:

```bash
cd examples/aspnet-sample
dotnet run --project AspNetRefreshSample.csproj
```

\::

::counter
::

Checkout out the [documentation](https://content.nuxt.com/docs/getting-started) to learn more.
