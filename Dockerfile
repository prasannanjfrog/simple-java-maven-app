FROM microsoft/dotnet-framework:4.7.2-runtime

LABEL maintainer="daniel.buchko@aveva.com"

COPY certs/ c:/tmp/certs

WORKDIR c:\\tmp\\certs

# Import zScaler, CORP and SE root certificates into Root Store
RUN certutil.exe -addstore "Root" ".\ZscalerRootCert.crt"
RUN certutil.exe -addstore "Root" ".\CA-corp-root.crt"
RUN certutil.exe -addstore "Root" ".\SE-root.crt"
# RUN certutil.exe -addstore "Root" ".\SE-subca.crt"

# Configure netsh for zScaler proxy
RUN netsh.exe winhttp set proxy proxy-server="http=gateway.schneider.zscaler.net:9480;https=gateway.schneider.zscaler.net:9480" bypass-list="*.dev.wonderware.com"

COPY scripts/ c:/tmp/scripts

WORKDIR c:\\tmp\\scripts

RUN powershell.exe -Command \
  Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process; \
  .\Set-RegistryInternetProxy.ps1; \
  .\Set-ZScalerProxy.ps1
