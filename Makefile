cleanup:
	rm -rf Dockerfile
	docker rmi -f tendermint-node
	rm -rf docker-entrypoint.sh
