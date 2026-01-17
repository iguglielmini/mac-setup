.PHONY: install doctor uninstall

install:
	@chmod +x setup.sh doctor.sh uninstall.sh
	@./setup.sh

doctor:
	@chmod +x doctor.sh
	@./doctor.sh

uninstall:
	@chmod +x uninstall.sh
	@./uninstall.sh
