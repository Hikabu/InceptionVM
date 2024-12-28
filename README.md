
for the secrets folder
export $(grep -v '^#' .env | xargs)
echo $secrets_dir
