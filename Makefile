export SIZE=1

install:
	@chmod +x ./shdb.sh 
	@./shdb.sh install --size $(SIZE)

clean:
	@./shdb.sh uninstall
