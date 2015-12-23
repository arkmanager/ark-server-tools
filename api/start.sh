if [ "$(type -t node)" = "file" ]; then
    node index.js
else
    nodejs index.js
fi
