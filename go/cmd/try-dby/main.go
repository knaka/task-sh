package main

import (
	"github.com/sirupsen/logrus"
	"github.com/ulfox/dby/db"

	//revive:disable:dot-imports
	. "github.com/knaka/go-utils"
	//revive:enable:dot-imports
)

func main() {
	logger := logrus.New()

	state, err := db.NewStorageFactory("/tmp/db.yaml")
	if err != nil {
		logger.Fatalf(err.Error())
	}
	logger.Infof("state: %v", state)
	//V0(state.AddDoc())
	V0(state.Read())
	keys, err := state.FindKeys("key-1")
	if err != nil {
		logger.Fatalf(err.Error())
	}
	logger.Info(keys)
	V0(state.Upsert(
		"some.path",
		map[string]string{
			"key-1": "value-1",
			"key-2": "value-2",
		},
	))
	//V0(state.Write())
}
