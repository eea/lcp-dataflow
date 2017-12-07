/**
 * Created by kasperen on 18.09.14.
 */
angular.module('ui.handsontable', [])
    .service('handsontableSrvc', function() {
    })
    .controller("HandsonController", function ($scope) {
		/*
		$scope.data = instance.LCPQuestionnaire.listOfPlants;
		$scope.data = [
			{
				"delete": false,
				"plantName": "1",
				"plantId": "",
				"eprtrNationalId": "",
				"address1": "",
				"address2": "",
				"city": "",
				"region": "",
				"postalCode": "",
				"longitude": "",
				"latitude": ""
			},
			{
				"delete": false,
				"plantName": "2",
				"plantId": null,
				"eprtrNationalId": null,
				"address1": null,
				"address2": null,
				"city": null,
				"region": null,
				"postalCode": null,
				"longitude": null,
				"latitude": null
			}
		];
		*/
	})
	.directive('uiHandsontable', function () {
		return {
			restrict: 'A',
			scope: {
				data: '='
			},
			replace: true,
			link: function (scope, elem, attrs) {
				elem.handsontable({
				data: scope.data,
                contextMenu: true,
				rowHeaders: true,
				minSpareRows: 1,
                colHeaders: ["Delete", "Plant Name", "Plant Id", "E-PRTR national ID", "Address 1", "Address 2", "City", "Region", "Postal code", "Longitude", "Latitude"],
                columns: [
                    {
                        data: "delete",
                        type: "checkbox"
                    },
                    {
                        data: "plantName"
                    },
                    {
                        data: "plantId",
                        type: 'numeric'
                    },
                    {
                        data: "eprtrNationalId",
                        type: 'numeric'
                    },
                    {
                        data: "address1"
                    },
                    {
                        data: "address2"
                    },
                    {
                        data: "city"
                    },
                    {
                        data: "region"
                    },
                    {
                        data: "postalCode",
                        type: 'numeric'
                    },
                    {
                        data: "longitude",
                        type: 'numeric',
                        format: '000.000'
                    },
                    {
                        data: "latitude",
                        type: 'numeric',
                        format: '000.000'
                    }
                ]
            })
        }
    }
	})