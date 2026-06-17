# ── Build stage ───────────────────────────────────────────────────────────────
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

COPY WorldCupStats.Api.csproj .
RUN dotnet restore

COPY . .
RUN dotnet publish -c Release -o /app/publish --no-restore

# ── Runtime stage ─────────────────────────────────────────────────────────────
FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS runtime
WORKDIR /app

COPY --from=build /app/publish .

# SeedData is embedded via the publish output; no extra COPY needed.
# SQLite DB will be created at runtime if absent (seeded from SeedData JSON).

ENV ASPNETCORE_ENVIRONMENT=Production

# PORT env var is injected by the host (e.g. Render) at runtime.
# EXPOSE is metadata only — the actual binding comes from Program.cs UseUrls.
EXPOSE 5050

ENTRYPOINT ["dotnet", "WorldCupStats.Api.dll"]
