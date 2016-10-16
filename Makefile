export SIZE=1

install:
	@sudo chmod +x ./src/shdb.sh 
	@sudo bash ./src/shdb.sh install --size $(SIZE)

clean:
	@sudo ./src/shdb.sh uninstall

test: 
	@sudo chmod +x ./demo/demo.sh
	@sudo bash ./demo/demo.sh 10