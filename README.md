# DNSDumpster

## Aim
* Tool for passive DNS enumeration with the [DNSDumpster free API](https://dnsdumpster.com/developer) (50 free queries/day)

## Done
* Query a single domain per run
* Query multiple domains from a file

## To do
* Generate Markdown and HTML reports

## Installation
* Create an account on [DNSDumpster](https://dnsdumpster.com/my-account/)
* Copy your API key
* Create a `.env` file
* In `.env` file, define `APIKEY` variable
* Install the packages in [requirements.txt](requirements.txt)

```bash
# Run
chmod +x dnsdumpster.sh
./dnsdumpster.sh
```
