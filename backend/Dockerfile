FROM node:24-slim AS base
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
ENV CI=true
RUN corepack enable
COPY ./backend /backend
WORKDIR /backend

FROM base AS dev
RUN --mount=type=cache,id=pnpm,target=/pnpm/store pnpm install --no-frozen-lockfile
CMD [ "pnpm", "run", "start:dev" ]

FROM base AS prod-deps
RUN --mount=type=cache,id=pnpm,target=/pnpm/store pnpm install --prod --frozen-lockfile --ignore-scripts

FROM base AS build
RUN --mount=type=cache,id=pnpm,target=/pnpm/store pnpm install --frozen-lockfile
RUN pnpm run build

FROM base AS final
COPY --from=prod-deps /backend/node_modules /backend/node_modules
COPY --from=build /backend/dist /backend/dist
COPY package.json ./
EXPOSE 4000
CMD [ "pnpm", "run", "start:prod" ]