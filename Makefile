export SIZE=1

install:
	@sudo chmod +x ./shdb.sh 
	@sudo bash ./shdb.sh install --size $(SIZE)

clean:
	@sudo ./shdb.sh uninstall

test: 
	@sudo chmod +x ./test.sh
	@sudo bash ./test.sh 10