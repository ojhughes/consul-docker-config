package main

import (
	consulApi "github.com/hashicorp/consul/api"
	vaultApi "github.com/hashicorp/vault/api"
	"os"
	"log"
	"net/http"
	"fmt"
)

const ServiceNameEnvKey = "SERVICE_NAME"

func main() {
	//Setup a webserver that retrieves the configuration from Consul
	http.HandleFunc("/", serve)
    if err := http.ListenAndServe(":8888", nil); err != nil {
        panic(err)
    }
}

func serve(response http.ResponseWriter, request *http.Request) {
	message := getMatch()
	response.Header().Set("Content-Type", "text/html; charset=utf-8")
	response.Write([]byte(message))
}

func getMatch() string {
	consulClient := getConsulClient()
	appScopedConfig := getConsulConfig(consulClient)
	sharedConfig := getSharedConfig(consulClient)
	vaultToken := getVaultKey(consulClient)
	nextMove := getNextMove(vaultToken)
	//Build an HTML image that links to the configured Pokemon
	pokemon := string(appScopedConfig.Value)
	gym := string(sharedConfig.Value)
	message := "<p style=\"font-family: 'Comic Sans MS', 'Comic Sans', cursive; font-size: 24px;\">" +
		"The chosen pokemon is: <br /><br />" + pokemon + "</p><br />"
	message += "<img src=\"https://img.pokemondb.net/artwork/" + pokemon + ".jpg\">"
	message += "<br /><br /><p style=\"font-family: 'Comic Sans MS', 'Comic Sans', cursive; font-size: 18px;\">" +
		"The battle takes place at: <b>" + gym + "</b></p>"
	message += "<br /><p style=\"font-family: 'Comic Sans MS', 'Comic Sans', cursive; font-size: 18px;\">" +
		"Their next move is:<b>" + nextMove + "</b></p><br />"
	return message
}
func getNextMove(vaultToken string) string {
	vaultConfig := vaultApi.DefaultConfig()
	vaultConfig.Address = "http://vault.service.consul:8200"
	vaultClient, err := vaultApi.NewClient(vaultConfig)
	check(err)
	vaultClient.SetToken(vaultToken)
	vault := vaultClient.Logical()
	nextMove, err := vault.Read("/secret/" + getServiceName() + "/nextmove")

	check(err)
	return fmt.Sprintf("%v", nextMove.Data["value"])
}

func getVaultKey(consulClient *consulApi.Client) string {
	consulServiceName := getServiceName()

	vaultTokenKey, _, err := consulClient.KV().Get("/service/vault/" + consulServiceName+"-token", nil)
	check(err)
	if vaultTokenKey == nil {
		log.Fatalln("Error accessing Consul ")
	}
	return string(vaultTokenKey.Value)
}

func getConsulConfig(consulClient *consulApi.Client) *consulApi.KVPair {
	//Lookup up the name of this service from the environment,
	//this will be used as the namespace in the KV store
	consulServiceName := getServiceName()
	//Query the key value and find the pokemon that has been configured for the app
	appScopedConfig, _, err := consulClient.KV().Get(consulServiceName+"/pokemon", nil)
	check(err)
	if appScopedConfig == nil {
		log.Fatalln("Error accessing Consul ")
	}
	return appScopedConfig
}

func getSharedConfig(consulClient *consulApi.Client) *consulApi.KVPair {
	//Lookup up the name of this service from the environment,
	//this will be used as the namespace in the KV store
	sharedConfig, _, err := consulClient.KV().Get("/shared/gym", nil)
	check(err)
	if sharedConfig == nil {
		log.Fatalln("Error accessing Consul ")
	}
	return sharedConfig
}

func getConsulClient() (*consulApi.Client) {
	//Build the Consul client, notice that we don't need to specify any
	//hard-coded URL as the environment variable CONSUL_HTTP_ADDR has been specified
	consulConfig := consulApi.DefaultConfig()
	consulConfig.Address = "consul.service.consul:8500"
	client, err := consulApi.NewClient(consulConfig)
	check(err)
	return client
}

func getServiceName() string {
	service := os.Getenv(ServiceNameEnvKey)
	if service == "" {
		log.Fatalln(ServiceNameEnvKey + " must be set as an environment variable")
	}
	return service
}

func check(err error) {
	if err != nil {

	}
}
