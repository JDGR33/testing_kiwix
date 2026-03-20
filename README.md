# Kiwix Server

This workspace runs a Kiwix server in Docker and serves ZIM files through a Kiwix library.

## Files

- `docker-compose.yml`: runs `kiwix-serve` on port `8080` in library mode
- `download_zim.sh`: downloads every URL from `./zim_links.txt` into `./data/` and refreshes the library
- `update_library.sh`: rebuilds `./data/library.xml` from every `*.zim` file in `./data/`
- `zim_links.txt`: list of ZIM URLs to download (one URL per line)

## Usage

1. Add the ZIM URLs you want to download to `zim_links.txt`.

2. Download all configured ZIM files:

   ```bash
   chmod +x download_zim.sh
   ./download_zim.sh
   ```

   This also creates or refreshes `./data/library.xml`.

   Optional: override paths with `./download_zim.sh <target_dir> <links_file>`.

3. If you add more `.zim` files manually to `./data/`, rebuild the library:

   ```bash
   ./update_library.sh
   ```

4. Start the server:

   ```bash
   docker compose up -d
   ```

5. Open the site:

   ```text
   http://localhost:8080
   ```

6. Stop the server:

   ```bash
   docker compose down
   ```

## Notes

- The ZIM file is large, so make sure the host has enough free disk space before downloading.
- The container mounts `./data` read-only and serves the ZIM files listed in `./data/library.xml`.
- If `library.xml` is missing or stale, run `./update_library.sh` before starting the container.
- `--monitorLibrary` is enabled, so a running server can reload the library when `library.xml` changes.
- The compose file uses `restart: "no"` so this fails once instead of restarting indefinitely.