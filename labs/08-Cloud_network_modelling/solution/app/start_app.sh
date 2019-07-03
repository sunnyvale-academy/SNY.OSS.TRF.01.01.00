#nohup nodejs ~/myapp/index.js & > /dev/null 2>&1

#nohup npm start & > /dev/null 2>&1

~/myapp/node_modules/forever/bin/forever start "/home/$USER/myapp/index.js"