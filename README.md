# Schedules Direct XMLTV Docker Service

This project provides a Docker container that automatically fetches TV schedule data from [Schedules Direct](https://www.schedulesdirect.org/) on a schedule, converts it to XMLTV format, and serves it via HTTP for use with various home media applications.

This is particularly useful to connect Schedules Direct with [Threadfin](https://github.com/Threadfin/Threadfin)

## Features

- Automatically fetches TV listings from Schedules Direct
- Converts listings to XMLTV format compatible with media center software
- Serves the XMLTV file via HTTP
- Periodically updates the listings data
- Runs in a Docker container for simple deployment

## Quick Start - Docker Compose

Copy the `docker-compose.yaml` file from this project and deploy it using your favorite docker deployment software (such as Dockge, Portainer, or just `docker compose up -d`)

Set the environment variables for your setup as described below.

## Prerequisites

- Docker and Docker Compose
- Schedules Direct subscription (username and password)

## Setup

1. Clone this repository:

   ```bash
   git clone https://github.com/johnpc/schedules-direct-update-and-serve.git
   cd schedules-direct-update-and-serve
   ```

2. Create a `.env` file with your Schedules Direct credentials:

   ```bash
   SCHEDULES_DIRECT_USERNAME=your_username
   SCHEDULES_DIRECT_PASSWORD=your_password
   ```

3. Start the container:

   ```bash
   docker-compose up -d
   ```

## Configuration

The service is pre-configured with several lineups:

- USA-0000001-CUSTOM
- USA-DITV505-X
- USA-MI21464-X
- USA-YOUTUBE-X

You can modify these lineups by editing the `start.sh` script and rebuilding the container.

## Usage

Once running, the XMLTV file is available at:

```bash
http://your-server-ip:51969/tvxml.xml
```

You can use this URL in your media center software (such as Threadfin, Plex, Emby, Jellyfin, TVHeadend, etc.) as the source for your TV guide data.

## How It Works

- The container runs a cron job that regularly updates the TV listings data
- `tv_grab_zz_sdjson` tool fetches data from Schedules Direct in JSON format
- The data is converted to XMLTV format
- Nginx serves the XMLTV file via HTTP on port 51969

## Environment Variables

| Variable | Description |
|----------|-------------|
| SCHEDULES_DIRECT_USERNAME | Your Schedules Direct username |
| SCHEDULES_DIRECT_PASSWORD | Your Schedules Direct password |
| TZ | Timezone (default: UTC. Since it runs every day at midnight, choose a TZ where that is the time you want it to run.) |

## Volumes

The Docker Compose configuration creates a volume named `xmltv_data` to store the fetched data, ensuring it persists between container restarts.

## Acknowledgements

This project uses the `tv_grab_zz_sdjson` tool to interact with the Schedules Direct API.
