FROM node:20-alpine AS deps
WORKDIR /app
ARG HTTP_PROXY
ARG HTTPS_PROXY
ARG NO_PROXY
ARG NPM_REGISTRY=https://registry.npmmirror.com
ENV HTTP_PROXY=${HTTP_PROXY}
ENV HTTPS_PROXY=${HTTPS_PROXY}
ENV NO_PROXY=${NO_PROXY}
ENV http_proxy=${HTTP_PROXY}
ENV https_proxy=${HTTPS_PROXY}
ENV no_proxy=${NO_PROXY}
ENV PUPPETEER_SKIP_DOWNLOAD=true
COPY package.json package-lock.json ./
RUN npm config set registry ${NPM_REGISTRY}     && if [ -n "$HTTP_PROXY" ]; then npm config set proxy "$HTTP_PROXY"; fi     && if [ -n "$HTTPS_PROXY" ]; then npm config set https-proxy "$HTTPS_PROXY"; fi     && npm ci --prefer-offline --no-audit --progress=false

FROM node:20-alpine AS builder
WORKDIR /app
ARG HTTP_PROXY
ARG HTTPS_PROXY
ARG NO_PROXY
ENV HTTP_PROXY=${HTTP_PROXY}
ENV HTTPS_PROXY=${HTTPS_PROXY}
ENV NO_PROXY=${NO_PROXY}
ENV http_proxy=${HTTP_PROXY}
ENV https_proxy=${HTTPS_PROXY}
ENV no_proxy=${NO_PROXY}
ENV PUPPETEER_SKIP_DOWNLOAD=true
COPY --from=deps /app/node_modules ./node_modules
COPY . .
ENV NEXT_TELEMETRY_DISABLED=1
ENV NEXT_PUBLIC_SUPABASE_URL=http://placeholder.invalid
ENV NEXT_PUBLIC_SUPABASE_ANON_KEY=placeholder-build-only
ENV SUPABASE_URL=http://placeholder.invalid
ENV SUPABASE_ANON_KEY=placeholder-build-only
ENV PII_SECRET=this-is-a-32-character-demo-secret-key-for-build
RUN npm run build

FROM node:20-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1
ENV PORT=3000
ENV HOSTNAME=0.0.0.0
RUN addgroup --system --gid 1001 nodejs \
    && adduser --system --uid 1001 nextjs
COPY --from=builder --chown=nextjs:nodejs /app/.next ./.next
COPY --from=builder --chown=nextjs:nodejs /app/public ./public
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./package.json
COPY patientmatch-entrypoint.sh /usr/local/bin/patientmatch-entrypoint
RUN chmod +x /usr/local/bin/patientmatch-entrypoint
USER nextjs
EXPOSE 3000
ENTRYPOINT ["patientmatch-entrypoint"]
CMD ["npm", "start"]
