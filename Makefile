export SIZE=1

install:
	@sudo chmod +x ./shdb.sh 
	@sudo bash ./shdb.sh install --size $(SIZE)

clean:
	@sudo ./shdb.sh uninstall