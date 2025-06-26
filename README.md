# qBittorrent Config Generator

A lightweight Docker container that generates qBittorrent configuration files with properly hashed passwords using PBKDF2 encryption.

## Overview

This tool creates a `qBittorrent.conf` file with a securely hashed password that can be used to configure qBittorrent instances. The password is hashed using PBKDF2-SHA512 with 100,000 iterations, matching qBittorrent's internal password hashing mechanism.

## Features

- ✅ Generates PBKDF2-SHA512 hashed passwords compatible with qBittorrent
- ✅ Configurable username and password via environment variables
- ✅ Minimal Alpine Linux container (~50MB)
- ✅ Output to mounted directory for easy integration
- ✅ Secure password handling (passwords are not logged)

## Quick Start

### Build the Container

```bash
docker build -t qbittorrent-config .
```

### Generate Configuration

```bash
# Basic usage with custom password
docker run --rm \
  -v $(pwd)/output:/output \
  -e QB_PASSWORD="mysecurepassword" \
  qbittorrent-config

# Custom username and password
docker run --rm \
  -v $(pwd)/output:/output \
  -e QB_USERNAME="myuser" \
  -e QB_PASSWORD="mysecurepassword" \
  qbittorrent-config
```

## Configuration Options

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `QB_USERNAME` | `admin` | qBittorrent WebUI username |
| `QB_PASSWORD` | `adminadmin` | qBittorrent WebUI password |
| `OUTPUT_DIR` | `/output` | Container directory where config is written |

### Volume Mounting

You must mount a directory to `/output` where the generated configuration file will be written:

```bash
-v /host/path/to/config:/output
```

## Usage Examples

### Generate config with default settings
```bash
docker run --rm -v $(pwd):/output qbittorrent-config
```

### Production setup with secure credentials
```bash
docker run --rm \
  -v /etc/qbittorrent:/output \
  -e QB_USERNAME="qbadmin" \
  -e QB_PASSWORD="$(openssl rand -base64 32)" \
  qbittorrent-config
```

### Using with Docker Compose

```yaml
version: '3.8'
services:
  config-generator:
    build: .
    environment:
      - QB_USERNAME=admin
      - QB_PASSWORD=your-secure-password
    volumes:
      - ./config:/output
```

## Output

The tool generates a `qBittorrent.conf` file with the following structure:

```ini
[Preferences]
WebUI\Password_PBKDF2=@ByteArray(base64-salt:base64-hash)
WebUI\Username=admin
```

## Integration with qBittorrent

1. Generate the configuration file using this tool
2. Copy `qBittorrent.conf` to your qBittorrent configuration directory:
    - **Linux**: `~/.config/qBittorrent/`
    - **Docker**: Mount to qBittorrent container's config directory
    - **Windows**: `%APPDATA%\qBittorrent\`

3. Restart qBittorrent to apply the new configuration

## Security Considerations

- **Password Security**: Passwords are hashed using PBKDF2-SHA512 with 100,000 iterations
- **Salt Generation**: Each password hash uses a cryptographically secure random salt
- **No Logging**: Passwords are never logged or displayed in plain text
- **Minimal Attack Surface**: Uses minimal Alpine Linux base image

## Docker Compose Example with qBittorrent

```yaml
version: '3.8'
services:
  qbittorrent-config:
    build: .
    environment:
      - QB_USERNAME=admin
      - QB_PASSWORD=secure-password-123
    volumes:
      - qb-config:/output
    
  qbittorrent:
    image: lscr.io/linuxserver/qbittorrent:latest
    depends_on:
      - qbittorrent-config
    ports:
      - "8080:8080"
    volumes:
      - qb-config:/config/qBittorrent
      - ./downloads:/downloads
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Etc/UTC

volumes:
  qb-config:
```

## Troubleshooting

### Error: "Output directory not found"
Ensure you've mounted a volume to `/output`:
```bash
docker run --rm -v $(pwd)/config:/output qbittorrent-config
```

### Permission Issues
If you encounter permission issues, ensure the mounted directory is writable:
```bash
chmod 755 ./config
```

### Invalid Configuration
If qBittorrent doesn't accept the generated config:
1. Verify the config file was generated successfully
2. Check file permissions
3. Ensure qBittorrent is completely stopped before replacing the config

## Development

### Local Development
```bash
# Make script executable
chmod +x entrypoint.sh

# Test locally (requires Python 3)
./entrypoint.sh
```

### Customization
The PBKDF2 parameters can be modified in `entrypoint.sh`:
- **Iterations**: Currently set to 100,000 (line 27)
- **Hash Algorithm**: SHA-512 (line 27)
- **Salt Length**: 16 bytes (line 25)

## License

This project is provided as-is for educational and utility purposes. Use responsibly and ensure compliance with your local laws and qBittorrent's terms of service.