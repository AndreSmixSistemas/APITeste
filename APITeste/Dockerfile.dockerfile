# Etapa 1: Build do ambiente
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

RUN apt-get update \
    && apt-get install -y libssl-dev ca-certificates libmariadb-dev \
    && rm -rf /var/lib/apt/lists/*

# Copia o arquivo de solução e restaura as dependências
COPY *.sln ./
COPY APITeste.csproj APITeste/



# Restaura todas as dependências
RUN dotnet restore

# Copia todos os arquivos e faz o build em Release
COPY . .
RUN dotnet publish APITeste.cspro -c Release -o /app/APITeste

# Etapa 2: Construção da imagem final
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS runtime
WORKDIR /app

# Copia o build das APIs
COPY --from=build /app/APITeste ./APITeste

# Expor portas para cada API
EXPOSE 5001  

# Script de inicialização para rodar todas as APIs em paralelo
CMD \
    dotnet /app/APITeste.API.dll --urls "http://0.0.0.0:5001" & \
    wait
