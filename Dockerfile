FROM mcr.microsoft.com/dotnet/aspnet:5.0 AS base
WORKDIR /app
EXPOSE 5000

FROM mcr.microsoft.com/dotnet/sdk:5.0 AS build
WORKDIR /src
COPY ["workspace.csproj", "./"]
RUN dotnet restore "workspace.csproj"
COPY . .
WORKDIR "/src/."
RUN dotnet build "workspace.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "workspace.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "workspace.dll"]
