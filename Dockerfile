# Etapa 1: Build do ambiente
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Instala as dependências necessárias
RUN apt-get update \
    && apt-get install -y libssl-dev ca-certificates libmariadb-dev \
    && rm -rf /var/lib/apt/lists/*

# Copia o arquivo de solução e o arquivo do projeto
COPY *.sln ./
COPY APITeste/APITeste.csproj APITeste/

# Restaura todas as dependências do projeto
RUN dotnet restore

# Copia todos os arquivos restantes e faz o build em Release
COPY . . 
RUN dotnet publish APITeste/ -c Release -o /app/APITeste

# Etapa 2: Construção da imagem final
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS runtime
WORKDIR /app

# Copia os arquivos gerados pelo build para o container
COPY --from=build /app/APITeste ./APITeste

# Expose the default Render port (10000)
EXPOSE 10000

# Command to run the app using the PORT environment variable
CMD ["dotnet", "/app/APITeste/APITeste.dll", "--urls", "http://0.0.0.0:$PORT"]
