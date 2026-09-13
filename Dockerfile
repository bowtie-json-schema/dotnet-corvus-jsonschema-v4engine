FROM --platform=$BUILDPLATFORM mcr.microsoft.com/dotnet/sdk:10.0.401 AS build
ARG TARGETARCH

WORKDIR /source

COPY *.csproj .
RUN dotnet restore -a ${TARGETARCH}

COPY . .
# ReadyToRun (PublishReadyToRun in the project) precompiles the harness and its dependencies for the target
# architecture; crossgen2 cross-compiles, so the arm64 image builds on the amd64 build host.
RUN dotnet publish -a ${TARGETARCH} --no-restore -c Release -o /app

FROM mcr.microsoft.com/dotnet/runtime:10.0-alpine
RUN apk add --no-cache icu-libs icu-data-full
ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=false
WORKDIR /app
COPY --from=build /app .
ENTRYPOINT ["dotnet", "bowtie_corvus_jsonschema_v4engine.dll"]
