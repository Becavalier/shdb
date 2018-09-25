export SIZE=1

install:
	@chmod +x ./shdb.sh 
	@bash ./shdb.sh install --size $(SIZE)

clean:
	@./shdb.sh uninstall