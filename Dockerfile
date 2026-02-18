FROM dart:stable AS build

WORKDIR /app

# Copy pubspec files
COPY pubspec.* ./

# Get dependencies
RUN dart pub get

# Copy source code
COPY . .

# Compile to native executable
RUN dart compile exe bin/server.dart -o bin/server

# Build minimal runtime image
FROM scratch

# Copy the executable from build stage
COPY --from=build /app/bin/server /app/bin/server
COPY --from=build /app/.env /app/.env

# Copy runtime dependencies
COPY --from=build /runtime/ /
COPY --from=build /lib/x86_64-linux-gnu/ /lib/x86_64-linux-gnu/
COPY --from=build /lib64/ /lib64/

EXPOSE 8080

WORKDIR /app

ENTRYPOINT ["/app/bin/server"]
