$.noConflict();


	var app = angular.module('LCP', [
        'ui.bootstrap',
        'ngAnimate',
        'ajoslin.promise-tracker',
        'navigation.navigationBlocker',
        'translate.languageChanger',
        'ui.multiselect',
        'tabs.formTabs',
        'ui.errorMapper',
        'monospaced.elastic',
        'ngOrderObjectBy',
        'notifications']);

    app.run(function($rootScope, promiseTracker, $location, tabService) {
        $rootScope.loadingTracker = promiseTracker({});
        tabService.setTabs([
            {"id":"BasicData",            "active" : true},
            {"id":"ListOfPlants",         "active" : false},
            {"id":"PlantDetails",         "active" : false},
            {"id":"EnergyInput",          "active" : false},
            {"id":"TotalEmissionsToAir",  "active" : false},
            {"id":"Desulphurisation",     "active" : false},
            {"id":"UsefulHeat",             "active" : false},
            {"id":"Notes",                "active" : false}]);
    });

    app.config(function (languageChangerProvider) {
        languageChangerProvider.setDefaultLanguage('en');
        languageChangerProvider.setLanguageFilePrefix('lcp-labels-');
        languageChangerProvider.setAvailableLanguages({ "item" :[{
            "code": "bg",
            "label": "Български (bg)"}, {
            "code": "es",
                "label": "Español (es)"}, {
            "code": "cs",
                "label": "Čeština (cs)"}, {
            "code": "da",
                "label": "Dansk (da)"}, {
            "code": "de",
                "label": "Deutsch (de)"}, {
            "code": "et",
                "label": "Eesti (et)"}, {
            "code": "el",
                "label": "ελληνικά (el)"}, {
            "code": "en",
                "label": "English (en)"}, {
            "code": "fr",
                "label": "Français (fr)"}, {
            "code": "hr",
                "label": "Hrvatski (hr)"}, {
            "code": "it",
                "label": "Italiano (it)"}, {
            "code": "lv",
                "label": "Latviešu valoda (lv)"}, {
            "code": "lt",
                "label": "Lietuvių kalba (lt)"}, {
            "code": "hu",
                "label": "Magyar (hu)"}, {
            "code": "hr",
                "label": "Hrvatski (hr)"}, {
            "code": "mt",
                "label": "Malti (mt)"}, {
            "code": "nl",
                "label": "Nederlands (nl)"}, {
            "code": "pl",
                "label": "Polski (pl)"}, {
            "code": "pt",
                "label": "Português (pt)"}, {
            "code": "ro",
                "label": "Română (ro)"}, {
            "code": "sk",
                "label": "Slovenčina (sk)"}, {
            "code": "sl",
                "label": "Slovenščina (sl)"}, {
            "code": "fi",
                "label": "Suomi (fi)"}, {
            "code": "sv",
                "label": "Svenska (sv)"}] })
    });

    // request parameters
    var baseUri = getParameterByName('base_uri');
    var fileId = getParameterByName('fileId');
    var envelope = getParameterByName('envelope');
    var sessionId = getParameterByName('sessionid');
    var countryCode = getParameterByName('countrycode');
    countryCode = countryCode === "GB" ? "UK" : countryCode;
    var DD_VOCABULARY_BASE_URI = "https://dd.eionet.europa.eu/vocabulary/";

    app.controller("questionnaire", function ($scope, $rootScope, dataRepository, languageChanger, $sce, $location, $timeout, $anchorScroll, $notification, $http, $filter ,$q) {

     
        $scope.codeList = {};
        $scope.regionsCodelist = {};

		$scope.base = $location.host()+ $location.port() + getParameterByName('base_uri');
        //$scope.availableLanguages = languageChanger.getAvailableLanguages();

        dataRepository.getEmptyInstance().error(function(){alert("Failed to read empty instance XML file.");}).success(function(instance) {
            $scope.emptyInstance = instance;
        });

        dataRepository.getInstance().error(function(){alert("Failed to read instance XML file.");}).success(function(instance) {
            if (!angular.isDefined(instance.LCPQuestionnaire)){
                // add labelLanguage attribute to correct location
                $scope.instance = {};
                $scope.instance.LCPQuestionnaire = {};
                $scope.instance.LCPQuestionnaire['@xmlns:xsi'] = instance.LCPQuestionnaire['@xmlns:xsi'];
                $scope.instance.LCPQuestionnaire['@xsi:noNamespaceSchemaLocation'] = instance.LCPQuestionnaire['@xsi:noNamespaceSchemaLocation'];
                $scope.instance.LCPQuestionnaire['@xml:lang'] = instance.LCPQuestionnaire['@xml:lang'];
                $scope.instance.LCPQuestionnaire.BasicData = instance.LCPQuestionnaire.BasicData;
                $scope.instance.LCPQuestionnaire.ListOfPlants = instance.LCPQuestionnaire.ListOfPlants;

            }
            else {
                $scope.instance = instance;
            }

            if ($scope.instance.LCPQuestionnaire.ListOfPlants && $scope.instance.LCPQuestionnaire.ListOfPlants.Plant) {

                // if therσυσe is only 1 plant, then convert it to array
                if (!angular.isArray($scope.instance.LCPQuestionnaire.ListOfPlants.Plant)) {
                    $scope.instance.LCPQuestionnaire.ListOfPlants.Plant = [$scope.instance.LCPQuestionnaire.ListOfPlants.Plant];
                }
                // remove the first empty row, if exists
                if ($scope.instance.LCPQuestionnaire.ListOfPlants.Plant.length == 1 &&
                        (!$scope.instance.LCPQuestionnaire.ListOfPlants.Plant[0] ||
                                (!$scope.instance.LCPQuestionnaire.ListOfPlants.Plant[0]['PlantName'] && !$scope.instance.LCPQuestionnaire.ListOfPlants.Plant[0]['PlantId']))){
                    $scope.instance.LCPQuestionnaire.ListOfPlants.Plant = [];

                    // Load predefined country specific plants
                    if( countryCode != null) {
                        var eprtrCountryCode = countryCode === "GB" ? "UK" : countryCode === "GR" ? "EL" : countryCode;
                        // var url = "lcp_plants-" + countryCode + ".json";
                        var url = "http://semantic.eea.europa.eu/sparql?format=application/json&query=";
                        var sparql = " PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>" +
                                    " PREFIX cr: <http://cr.eionet.europa.eu/ontologies/contreg.rdf#> " +
                                    " PREFIX prtr: <http://prtr.ec.europa.eu/rdf/schema.rdf#> " +
                                    " PREFIX geo: <http://www.w3.org/2003/01/geo/wgs84_pos#>" +
                                    " PREFIX lcpType: <http://semantic.eea.europa.eu/project/lcp_data/lcp_plants.csv/> " +
                                    " PREFIX lcp: <http://semantic.eea.europa.eu/project/lcp_data/lcp_plants.csv#> " +
                                    " SELECT *" +
                                    " WHERE {" +
                                    " {" +
                                        " [] a lcpType:lcpPlant ;" +
                                        " lcp:PlantName ?PlantName;" +
                                        " lcp:MemberState ?MemberState;" +
                                        " lcp:EPRTRNationalId ?EPRTRNationalId;" +
                                        " lcp:Unique_Plant_ID ?PlantId." +

                                        " ?facility a prtr:Facility ;" +
                                        " prtr:facilityName ?facilityName;" +
                                        " prtr:streetName ?streetName;" +
                                        " prtr:postalCode  ?postalCode;" +
                                        " geo:lat ?lat;" +
                                        " geo:long ?long;" +
                                        " prtr:inCountry ?inCountry ;" +
                                        " prtr:latestReport ?latestReport." +
                                        " ?inCountry prtr:code ?EPRTRCountryCode." +
                                        " ?latestReport prtr:nationalID ?EPRTRNationalId;" +
                                        " prtr:forNUTS ?forNUTS;" +
                                        " prtr:reportingYear ?reportingYear." +
                                        " ?forNUTS prtr:code ?regionCode." +
                                        " OPTIONAL { ?facility prtr:buildingNumber ?buildingNumber. }" +
                                        " OPTIONAL { ?facility prtr:city ?city. }" +
                                        " FILTER( ?EPRTRCountryCode= '" + eprtrCountryCode + "' and ?MemberState = '" + countryCode + "' and ?MemberState != 'SK' )" +
                                    " } " +
                                    " UNION" +
                                    " {" +
                                        " ?plant a lcpType:lcpPlant ;" +
                                        " lcp:PlantName ?PlantName;" +
                                        " lcp:MemberState ?MemberState;" +
                                        " lcp:EPRTRNationalId ?EPRTRNationalId;" +
                                        " lcp:Unique_Plant_ID ?PlantId." +
                                        " OPTIONAL {  ?plant lcp:FacilityName ?facilityName. }" +
                                        " OPTIONAL {  ?plant lcp:Longitude ?long. }" +
                                        " OPTIONAL {  ?plant lcp:Latitude ?lat. }" +
                                        " OPTIONAL {  ?plant lcp:Address1 ?streetName. }" +
                                        " OPTIONAL {  ?plant lcp:City ?city. }" +
                                        " OPTIONAL {  ?plant lcp:PostalCode ?postalCode.}" +
                                        " OPTIONAL {  ?plant lcp:Region ?regionCode. }" +
                                        " OPTIONAL {" +
                                            " ?facility a prtr:Facility ;" +
                                            " prtr:inCountry ?inCountry ;" +
                                            " prtr:latestReport ?latestReport." +
                                            " ?latestReport prtr:nationalID ?EPRTRNationalId." +
                                            " ?inCountry prtr:code ?EPRTRCountryCode." +
                                            " FILTER( ?EPRTRCountryCode= '"+ eprtrCountryCode + "'  )" +
                                        " }" +
                                        " FILTER( ?MemberState = '" + countryCode +"' and (!bound(?facility) or  ?MemberState = 'SK' ) ) " +
                                    " }" +
                                 " } ORDER BY ?PlantId ";

                        url = baseUri + '/restProxy?uri=' + encodeURIComponent(url + encodeURIComponent(sparql));
        //                console.log('plants url is:'+url);
                        $http.get(url, {tracker : $rootScope.loadingTracker})
                                .error(function(){alert("Failed to pre-load plants data from E-PRTR database.");})
                                .success(function(eprtrData) {
                                    if (eprtrData.results.bindings.length > 0) {
                                        var plantsDict = {} ;
                                        for (var i= 0; i < eprtrData.results.bindings.length; i++) {
                                            var responsePlant = eprtrData.results.bindings[i];
                                            var plant = null ;
                                            if (   plantsDict[ responsePlant.PlantId.value] && plantsDict [ responsePlant.PlantId.value] > responsePlant.reportingYear.value  ) {
                                                // some plants have reports under different facilities. we keep the for most new reportingYear
                                                continue ;
                                            }
                                            else if ( ! plantsDict[ responsePlant.PlantId.value] ){
                                                $scope.addItem('LCPQuestionnaire.ListOfPlants.Plant');
                                            }

                                            plant = $scope.instance.LCPQuestionnaire.ListOfPlants.Plant[ $scope.instance.LCPQuestionnaire.ListOfPlants.Plant.length - 1 ];
                                            if (!plant.PlantLocation) plant.PlantLocation = {};
                                            if (!plant.GeographicalCoordinate) plant.GeographicalCoordinate = {};

                                            plant.PlantId = responsePlant.PlantId.value ;
                                            plant.PlantName = responsePlant.PlantName.value;
                                            plant.EPRTRNationalId = responsePlant.EPRTRNationalId.value;
                                            plant.PlantLocation.Address1 = responsePlant.streetName.value;
                                            if (!isEmpty(responsePlant.buildingNumber.value)) {
                                                plant.PlantLocation.Address1 += " " + responsePlant.buildingNumber.value;
                                            }
                                            plant.PlantLocation.City = responsePlant.city.value;
                                            plant.PlantLocation.Region = responsePlant.regionCode.value;
                                            plant.PlantLocation.PostalCode = responsePlant.postalCode.value;
                                            plant.GeographicalCoordinate.Longitude = responsePlant.long.value;
                                            plant.GeographicalCoordinate.Latitude = responsePlant.lat.value;
                                            plant.FacilityName = responsePlant.facilityName.value;

                                            plantsDict [plant.PlantId ] = responsePlant.reportingYear.value || 2013;
                                        }
                                        $rootScope.$broadcast('updateFilter');
                                        $notification.info("Info", "Previous EPRTR plants have been pre-loaded.");

                                    }
                                    else {
                                        alert("The system could not find any plant for country " + countryCode);
                                    }
                                });
                    }
                }
            }
            else {
                $scope.instance.LCPQuestionnaire.ListOfPlants = {"Plant" : []};
            }
            if( countryCode != null){

                $scope.countryCodeBoolean =true;
                $scope.instance.LCPQuestionnaire.BasicData.MemberState = countryCode.toUpperCase();
                $scope.memberStateValue = countryCode;
            }

            if( $scope.instance.LCPQuestionnaire.BasicData.MemberState != null ){
                $scope.countryCodeBoolean =true;
                $scope.memberStateValue = $scope.instance.LCPQuestionnaire.BasicData.MemberState;
                $scope.stateValue = $scope.instance.LCPQuestionnaire.BasicData.MemberState;
                $scope.instance.LCPQuestionnaire.BasicData.State = $scope.stateValue;
                $scope.regionsCodelist = dataRepository.loadRegionsCodelist($scope.memberStateValue);
            }

            $scope.$broadcast('instanceReady');
        });

   
        
        $scope.reportingYears = [];
        $scope.reportingYears.push ('2016');
        $scope.plantDetailsOtherSectorFieldsView = {iron_steel:"Iron and Steel",esi:"Electricity production",district_heating:"District heating",chp:"Combined heat and power generation",other:"Other"};

        // new
        $scope.currentListOfPlantsTable = null;
        $scope.selectedListOfPlantsTable = null;
        $scope.translationData = {};
        $rootScope.bulkEditListOfPlants=false;
        //$scope.status = submissionService.getStatus();
        $scope.profileFilled = true;
        $scope.editReference = false;
        $scope.changedReference = "";
        $scope.editUserIdentity = false;
        $scope.changedUserIdentity = "";
        $scope.editCountry = false;
        $scope.changedCountry = "";
        $scope.regionsCodelist = {};
        $scope.regionsCountry = null;
        $scope.isIE9 = $rootScope.isIE9;

        $scope.checkBoxDeleteCommit = false;
        // new end
        //determine ie version, code snippet is taken from: http://msdn.microsoft.com/en-us/library/ms537509%28v=vs.85%29.aspx
        var rv = -1; // Return value assumes failure.
        if (navigator.appName == 'Microsoft Internet Explorer')
        {
            var ua = navigator.userAgent;
            var re  = new RegExp("MSIE ([0-9]{1,}[\.0-9]{0,})");
            if (re.exec(ua) != null)
                rv = parseFloat( RegExp.$1 );
        }
        //see: http://stackoverflow.com/questions/17907445/how-to-detect-ie11
        else if (navigator.appName == 'Netscape')
        {
            var ua = navigator.userAgent;
            var re  = new RegExp("Trident/.*rv:([0-9]{1,}[\.0-9]{0,})");
            if (re.exec(ua) != null)
                rv = parseFloat( RegExp.$1 );
        }

        $rootScope.ieVersionNumberOutOfCuriosityVariable = rv;
        if (rv > 0 && rv <= 9.0){
            $rootScope.isIE9 = true;
        }else{
            $rootScope.isIE9 = false;
        }
        $rootScope.$watch('isIE9', function(newValue, oldValue) {
            if (!newValue) {
                return;
            } else {
                $scope.isIE9 = $rootScope.isIE9;
            }
        })


        //$scope.countryCodeBoolean =  countryCode != null  ;
        $scope.countryCodeVal =  countryCode;


        dataRepository.loadCodeList();
        dataRepository.loadOldLCPCodeList();
        dataRepository.loadCombustionPlantCodeList();
        dataRepository.loadDerogationValueCodeList();
        dataRepository.loadOtherSolidFuelCodeList();
        dataRepository.loadOtherGasesousFuelCodeList();
        dataRepository.loadMonthValueCodeList();
        $scope.codeList = dataRepository.getCodeList();

       
    
        $scope.conversionLink = "";
        $scope.instanceInfo = {};
        dataRepository.loadInstanceInfo().error(function(){console.log("Failed to readfile info from server.");}).success(function(info) {
            angular.copy(info, $scope.instanceInfo);
            if ($scope.instanceInfo.conversions) {
                var htmlConversionId = $filter('filter')($scope.instanceInfo.conversions, {resultType: 'HTML'})[0].id;
                $scope.conversionLink = $scope.instanceInfo.conversionLink + htmlConversionId;
            }
        })


        // Remove row from ng-repeat.
        $scope.remove = function(array,  rowElement, showMsg){

            ////console.log(rowElement);
            ////console.log(countNonEmptyProperties(rowElement));
            if(showMsg == true){
                if (countNonEmptyProperties(rowElement) > 0) {
                    if (!confirm('Are you sure you want to delete the data in this row?')){
                        return;
                    }
                }
            }
            var index = array.indexOf(rowElement);
            array.splice(index, 1);
            $rootScope.$broadcast('updateFilter');
        };


        // get code list label by code
        $scope.getCodeListLabel = function(codelist, code) {
            //Do not try to get codeList before it actually exists.
            if (!$scope.codeList) {
                return;
            }

            //Escape codelists that are not arrays by default (has only one element)
            // This code can be removed when changes are made to codeList file.
            if (!($scope.codeList.LCPCodelists[codelist].item.length > 0)
                    && $scope.codeList.LCPCodelists[codelist].item.code == code) {
                return $scope.codeList.LCPCodelists[codelist].item.label;
            }

            var retValue;
            for (var i=0 ; i<=$scope.codeList.LCPCodelists[codelist].item.length - 1; i++) {
                if ($scope.codeList.LCPCodelists[codelist].item[i].code == code) {
                    retValue = $scope.codeList.LCPCodelists[codelist].item[i].label;
                    break;
                }
            }
            return retValue;
        };


        $scope.addItem = function(path) {

            var tokens = path.split(".");
            var result = $scope.instance;
            while(tokens.length) {
                result = result[tokens.shift()];
            }
            if (!(result instanceof Array)) {
                result = [];
            }
            // Need to make copy of object otherwise it gets same $$hashkey and it cannot be used in ng-repeat.
            // Other solution would be to get empty instance every time that would be slower.
            var copyOfEmptyInstance = clone($scope.getInstanceByPath('emptyInstance', path));
            result.push(copyOfEmptyInstance);
            return copyOfEmptyInstance;
        };

        $scope.getNextPlantId = function ( plantId_candidate ) {
            //
            var q = $q.defer ();

            var formNextPlantId = 1;
            var newPlantId = null;

            function pad(num, size) {
                var s = num+"";
                while (s.length < size) s = "0" + s;
                return s;
            }

            function checkSDS ( newPlantId ) {
                var url = "http://semantic.eea.europa.eu/sparql?format=application/json&query=";

                var sparql =
                    " PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>" +
                    " PREFIX lcpType: <http://semantic.eea.europa.eu/project/lcp_data/lcp_plants.csv/>" +
                    " PREFIX lcp: <http://semantic.eea.europa.eu/project/lcp_data/lcp_plants.csv#>" +
                    " SELECT *" +
                    " WHERE {" +
                    " ?plant a lcpType:lcpPlant ;" +
                    " lcp:Unique_Plant_ID ?PlantId." +
                    " FILTER ( ?PlantId = '" + newPlantId +"' )" +
                    " }" ;

                url = baseUri + '/restProxy?uri=' + encodeURIComponent(url + encodeURIComponent(sparql));
                $http.get(url, {tracker : $rootScope.loadingTracker})
                            .error(function(){alert("Failed to read data from remote database. Please check your connection."); q.reject();})
                            .success(function(eprtrData) {
                                if (eprtrData.results.bindings.length > 0) { // plandId exists in db
                                    // check against the next increment of plantid
                                    newPlantId =   ($scope.memberStateValue || $scope.instance.LCPQuestionnaire.BasicData.MemberState) + pad( parseInt( newPlantId.slice(2) ) + 1 , 4 ) ;
                                    $scope.getNextPlantId ( newPlantId ) . then ( function ( value ) {
                                        q.resolve ( value ) ;
                                    } ) ;
                                }
                                else { // plantid not reserved. resolve the promise
                                    q.resolve ( newPlantId ) ;
                                }
                });
            }

            if ( plantId_candidate == null )
            { // plantId_candidate == null on the first call of the function
                // we get the max plant id of the current plants on th form
                // and the max plant id from sds
                // then we will check for id collisions and increment by one the id and recheck, until a 'free' plant id is found

                var orderBy = $filter('orderBy');
                var orderedItems = orderBy( $scope.instance.LCPQuestionnaire.ListOfPlants.Plant, "PlantId", true);

                for (var i=0; i < orderedItems.length; i++) {
                            if (!isEmpty(orderedItems[i].PlantId ) && orderedItems[i].PlantId !== "" ) {
                                formNextPlantId = parseInt(orderedItems[i].PlantId.substring(orderedItems[i].PlantId.length - 4 )) + 1;
                                break;
                            }
                }


                // ---- query the sds for the max id
                var url = "http://semantic.eea.europa.eu/sparql?format=application/json&query=";

                var sparql =
                    " PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>" +
                    " PREFIX lcpType: <http://semantic.eea.europa.eu/project/lcp_data/plant_IDs.csv/>" +
                    " PREFIX lcp: <http://semantic.eea.europa.eu/project/lcp_data/plant_IDs.csv#> " +
                    " SELECT *" +
                    " WHERE {" +
                    " [] a lcpType:lcpPlantIds ;" +
                    " lcp:Unique_Plant_ID ?PlantId." +
                    " FILTER ( regex(?PlantId,'" +  ($scope.memberStateValue || $scope.instance.LCPQuestionnaire.BasicData.MemberState) +"') )" +
                    " }  ORDER BY DESC(?PlantId) LIMIT 1 " ;

                url = baseUri + '/restProxy?uri=' + encodeURIComponent(url + encodeURIComponent(sparql));
                $http.get(url, {tracker : $rootScope.loadingTracker})
                            .error(function(){alert("Failed to read data from remote databse. Please check your connection"); q.reject();})
                            .success(function(eprtrData) {
                                var nextId;
                                if ( eprtrData.results.bindings.length > 0 ) {
                                nextId = parseInt( eprtrData.results.bindings[0].PlantId.value.slice(2) ) + 1 ;
                                if ( formNextPlantId > nextId ) nextId = formNextPlantId ;
                            }
                                else nextId = formNextPlantId;

                                    newPlantId =   ($scope.memberStateValue || $scope.instance.LCPQuestionnaire.BasicData.MemberState) +
                                                    pad(  nextId , 4 ) ;
                                    checkSDS ( newPlantId ) ;

                });

            }
            else {
                checkSDS ( plantId_candidate ) ;
            }

            return q.promise ;

        }

        $scope.getMaxPlantId = function() {
            var orderBy = $filter('orderBy');
            var orderedItems = orderBy( $scope.instance.LCPQuestionnaire.ListOfPlants.Plant, "PlantId", true);
            var nextPlantId = 1;
            var newPlantId = null;
            var exists = null;

            for (var i=0; i < orderedItems.length; i++) {
                if (!isEmpty(orderedItems[i].PlantId ) && orderedItems[i].PlantId !== "" ) {
                    nextPlantId = parseInt(orderedItems[i].PlantId.substring(orderedItems[i].PlantId.length - 4 )) + 1;
                    break;
                }
            }
            // format the id : XXNNNN, where XX is the memberstate code and NNNN is a unique integer
            function pad(num, size) {
                var s = num+"";
                while (s.length < size) s = "0" + s;
                return s;
            }

            newPlantId =  ($scope.memberStateValue || $scope.instance.LCPQuestionnaire.BasicData.MemberState) + pad( nextPlantId, 4);

            return newPlantId;
        }

        $rootScope.getInstanceByPath = function(root, identifier) {
            //console.log(root);
            if (!$scope.instance) {
                return null;
            }

            var tokens = root.split(".");
            //console.log(tokens);
            var result = $scope;

            while(tokens.length) {
                result = result[tokens.shift()];
                if (!result) {
                    return null;
                }
            }

            tokens = identifier.split(".");

            while(tokens.length) {
                result = result[tokens.shift()];
            }

            return result;
        };

        $rootScope.getPlantByPath = function(plant, identifier) {
            //console.log(root);
            if (!$scope.instance) {
                return null;
            }

            var result;
            //console.log(tokens);
            if(plant != null){
             result = plant;
            }


            var tokens = identifier.split(".");

            while(tokens.length) {
                result = result[tokens.shift()];
            }

            return result;
        };

        // save instance data.
        $scope.saveInstance = function(){

            //$scope.submitted = true;
            var passedTheQas = $scope.runQAtests();
            var formComplete = $scope.isFormComplete();

			dataRepository.saveInstance($scope.instance).error(function(){

                $notification.error("Save", "Data was not saved !");})

            .success(function(response){
                if ( response.code === 0 ) {
                  alert("There was an error during the save operation. Data is not saved.")
                  return;
                }

                if ($scope.appForm.$invalid || ( !formComplete) ) {
                    $notification.info("Save", "Data was saved, but the questionnaire is incomplete.");
                }
                else if (!passedTheQas) {
                    $notification.info("Save", "Data was saved, but the questionnaire did not pass some QAs.");
                }
                else {
                    $notification.success("Save", "Data is saved successfully.");
                }

                $scope.appForm.$setPristine(true);

            });

        };

         $scope.hasArticle31DerogationValue = function(item){
             // check against this value: http://dd.eionet.europa.eu/vocabularyconcept/euregistryonindustrialsites/DerogationValue/Article31/
             if(item.PlantDetails!=null && item.PlantDetails.Derogation!= null){
                 if(item.PlantDetails.Derogation.indexOf("Article31") !== -1) {
                    return true;
                }
                else {
                    return false;
                }
             }
             return false;
         }

         $scope.hasArticle35DerogationValue = function(item){
             // check against this value: http://dd.eionet.europa.eu/vocabularyconcept/euregistryonindustrialsites/DerogationValue/Article35/
             if(item.PlantDetails!=null && item.PlantDetails.Derogation!= null){
                 if(item.PlantDetails.Derogation.indexOf("Article35") !== -1) {
                    return true;
                }
                else {
                    return false;
                }
             }
             return false;
         }


         $scope.addDesulphurizationValuesForEachMonth=function(i,plant){
                 plant.Desulphurisation.push({
                    "MonthValue":$scope.codeList.MonthlyDesulphurisation[i].MonthValue,
                    "DesulphurisationRate": $scope.codeList.MonthlyDesulphurisation[i].DesulphurisationRate,
                    "SulphurContent": $scope.codeList.MonthlyDesulphurisation[i].SulphurContent,
                    "TechnicalJustification": $scope.codeList.MonthlyDesulphurisation[i].TechnicalJustification,
                 })
         }
        $scope.isFormComplete = function () {
            // returns true if the required fields for all plant are filled; false if not ~

            var res = true;
            var plants = $scope.instance.LCPQuestionnaire.ListOfPlants.Plant;
            var plant = null;
            var j = null;

            for ( i=0 ; i < plants.length; i++) {
                plant = plants[i];
                // list of plants
                if ( isEmpty (plant.PlantId) || isEmpty( plant.GeographicalCoordinate.Latitude) || isEmpty ( plant.GeographicalCoordinate.Longitude)   )
                    res = false;

                // plant details
                if ( isEmpty ( plant.PlantDetails.MWth) )
                    res = false;

                // energy input
               
                for  ( j in ( ( plant.EnergyInputAndTotalEmissionsToAir.EnergyInput)) ) {
                    if  ( isEmpty (plant.EnergyInputAndTotalEmissionsToAir.EnergyInput[ j]) )
                        plant.EnergyInputAndTotalEmissionsToAir.EnergyInput[ j] = 0;
                }

                for ( j in ( ( plant.EnergyInputAndTotalEmissionsToAir.TotalEmissionsToAir)) ) {
                    if (isEmpty (plant.EnergyInputAndTotalEmissionsToAir.TotalEmissionsToAir[ j]))
                        plant.EnergyInputAndTotalEmissionsToAir.TotalEmissionsToAir[ j] = 0;
                }

                for ( j in ( ( plant.Desulphurisation)) ) {
                    if (isEmpty (plant.Desulphurisation[ j]))
                        plant.Desulphurisation[ j] = 0;
                }
                for ( j in ( ( plant.UsefulHeat)) ) {
                    if (isEmpty (plant.UsefulHeat[ j]))
                        plant.UsefulHeat[ j] = 0;
                }


                if (res === false) break;
            }

            return res;


        }


        $scope.runQAtests = function () {

            // conform the instance if needed

            var res = true;
            var plants = $scope.instance.LCPQuestionnaire.ListOfPlants.Plant;

            if (plants.length != $scope.instance.LCPQuestionnaire.BasicData.NumberOfPlants)
                res = false;

            var sectors = {};
            var status  = {};

   //         for (i in $scope.codeList.LCPCodelists.sectors.concepts) {  sectors[ $scope.codeList.LCPCodelists.sectors.concepts[ i ] ['@id'] ] = 1 ; }
            // sectors is a dictionary of valid other sector values

        //    for (i in $scope.codeList.LCPCodelists.status.concepts) {  status[ $scope.codeList.LCPCodelists.status.concepts[ i ] ['@id'] ] = 1 ; }

            var names = {};
            var dublicates = {};
            var refDay = new Date("2003-11-27");

            for ( i=0 ; i < plants.length; i++) {

                // LCP 1.1
                // not refinery

                if ( !plants[i].PlantDetails) continue; // some times a null plant was present at the end of the array

                // coordinates
                if ( plants[i].GeographicalCoordinate.Longitude > 180 || plants[i].GeographicalCoordinate.Longitude < -180)
                    res = false;

                if ( plants[i].GeographicalCoordinate.Latitude > 90 || plants[i].GeographicalCoordinate.Latitude < -90)
                    res = false;
                //
           //     if ( !( plants[i].PlantDetails.Refineries) && ( !( plants[i].PlantDetails.OtherSector  )  || ! (sectors[plants[i].PlantDetails.OtherSector ] )) ){
                    // ^^ checks that if not Refineries, that OtherSector is filled with one of the permitted values(fetched from DD)
            //        res = false;
             //   }

          

                // LCP 2.1 Unequivocal naming of plants
                if ( names[ plants[i].PlantName ] != undefined ) {
                    // dublicate found
                    dublicates[i] = 1;
                    dublicates[ names[ plants [i].PlantName ] ] = 1;
                    //names[$scope.instance.LCPQuestionnaire.ListOfPlants.Plant[i].PlantName ].push(i);
                }
                else
                    names[ plants [i].PlantName] = i;

                // LCP 3.2

                if ( plants[i].PlantDetails.MWth < 50 ){
                    // error
                    res = false;
                }
                else if ( plants[i].PlantDetails.MWth > 10000){
                    // warning
                    console.log(i);
                }

                // LCP 3.4
              
                // LCP 3.5
             
                // LCP 3.6
                // valid dates(if date submitted)
                if ( !$scope.validDateFormat(plants[i].PlantDetails.DateOfStartOfOperation)) {
                        res = false;
                    }
               
           

            }// end for
            if ( JSON.stringify(dublicates) !== "{}") {
                // duplicates holds the plants with same names
                console.log(dublicates);
                res = false;
            }
            if ( res === true )  $scope.conformTheInstance();
            return res;
        }

        $scope.conformTheInstance = function () {

            var plants = $scope.instance.LCPQuestionnaire.ListOfPlants.Plant;
            for (j in plants){

                plant = plants[j];

                delete plant.Delete;

                
                if ( plant.plantDetails!=null && plant.PlantDetails.Refineries !== true ){
                    plant.PlantDetails.Refineries = false;
                }
                if (plant.plantDetails!=null && plant.PlantDetails.Refineries === true ){
                    //plant.PlantDetails.OtherSector = null;
                }
               

            }

        }

        $scope.ifFormIsValidSaveInstance = function(form){
            if (!form.$invalid) {
                $scope.saveInstance();
            }

        }

        $scope.validationOnOff = function() {
            $scope.submitted = !$scope.submitted;
        };

        // save instance data.
        $scope.close = function(){
            if (baseUri == ''){baseUri = "/"};
            var windowLocation = (envelope && envelope.length > 0) ? envelope : baseUri;
            if ($scope.appForm.$dirty){
                if (confirm('You have made changes in the questionnaire! \n\n Do you want to leave without saving the data?')){
                    window.location = windowLocation;
                }
            }
            else {
                ////console.log("Failed to confirm");
                window.location = windowLocation;
            }
        };
        // convert XML to HTML in new window.
        $scope.printPreview = function(){
            dataRepository.saveInstance($scope.instance).success(function(){
				var win = window.open($scope.conversionLink, '_blank');
				win.focus;
			});
        };
        $scope.closeBulkEditListOfPlants = function(form){
            //if (form && form == 'ListOfPlants'){
                //remove empty rows
                for(var i = $scope.instance.LCPQuestionnaire.ListOfPlants.Plant.length - 1; i >= 0; i--){

                    var plant = $scope.instance.LCPQuestionnaire.ListOfPlants.Plant[i];

                    if ( plant.PlantLocation!=null && isEmpty(plant.PlantName)  && isEmpty(plant.EPRTRNationalId) &&
                           isEmpty(plant.PlantLocation.Address1) && isEmpty(plant.PlantLocation.Address2) &&
                           isEmpty(plant.PlantLocation.City) && isEmpty(plant.PlantLocation.Region) && isEmpty(plant.PlantLocation.PostalCode) &&
                           isEmpty(plant.GeographicalCoordinate.Longitude) && isEmpty(plant.GeographicalCoordinate.Latitude) && isEmpty(plant.FacilityName))

                    {
                        $scope.instance.LCPQuestionnaire.ListOfPlants.Plant.splice(i, 1);
                        continue;
                    }
                    // fill in plant IDs

                    if ( isEmpty(plant.PlantId) ) {
                        var promise = $scope.getNextPlantId () ;
                        var newPlant = plant;
                        // using $q promise API, to ask the server first for id collisions.
                        promise.then ( function ( plantid ) {
                            newPlant.PlantId = plantid ;
                        });

                    }
                }
            //}
            $scope.conformTheInstance();
            //
            $rootScope.bulkEditListOfPlants = false;
            $rootScope.$broadcast('updateFilter');
        };
        $scope.openBulkEditListOfPlants = function(form) {
            if (form && form === 'ListOfPlants') {
                $scope.addItem('LCPQuestionnaire.ListOfPlants.Plant');
            }
            if ($scope.instance.LCPQuestionnaire.ListOfPlants.Plant.length === 0) {

                $notification.info("Edit", "Add some plants from List of Plants first.");

            }
            else
            $rootScope.bulkEditListOfPlants = true;
        };

        $scope.windowSearch = window.location.search;

        $scope.getHelpInfo = function(divId) {
            //console.log(divId);
            var infoDiv = document.getElementById(divId);
            //console.log(infoDiv);
            return $sce.trustAsHtml(infoDiv.innerHTML);
        };

        $scope.changeInfoToggle = function(overInfoToggle) {
            $scope.showInfo = overInfoToggle;
        };

        $scope.phoneNumberPattern = /^[ 0-9\(\)\+\-]{7,25}$/;
        $scope.positiveIntegerPattern = /^\d+$/;
        $scope.positiveDecimalNumberPattern = /^\d*\.?\d*$/;
        $scope.binaryNumberPattern=/^[0-1]+$/;
        $scope.decimalNumberPattern =/^[+-]?(\d*\.?\d*)$/;
        $scope.dateFormat = /^(19|20)\d\d([-])(0[1-9]|1[012])\2(0[1-9]|[12][0-9]|3[01])$/;

        $scope.websiteAddressPattern = /^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$/;
        $scope.percentagePattern = /^100$|^[0-9]{1,2}$|^[0-9]{1,2}\,[0-9]{1,3}$/;
        $scope.longitudeNumberPattern = /^[-+]?(180(\.0+)?|((1[0-7]\d)|([1-9]?\d))(\.\d+)?)$/;

        $scope.latitudeNumberPattern = /^[-+]?([1-8]?\d(\.\d+)?|90(\.0+)?)$/;

        $scope.isFixedQuestion = function(dataPath) {
            var tokens = dataPath.split('.');
            var lastToken = tokens.pop();
            ////console.log(lastToken);
            ////console.log(lastToken == 'FixedQuestion');
            return (lastToken == 'FixedQuestion');
        }

        $scope.clearSubFormData = function(dataPaths, identifierPath, changeValueTo) {

            var elementCount = 0;
            for (var i = 0; i < dataPaths.length; i++) {
                var formElementInstance = $scope.getInstanceByPath('instance.LCPQuestionnaire', dataPaths[i]);
                elementCount += countNonEmptyProperties(formElementInstance, $scope.isFixedQuestion(dataPaths[i]));
            }

            // Need to get parent path of yes/no question otherwise assigning new value
            // to property does not work.
            var tokens = identifierPath.split('.');

            // Parent property of actual yes/no question
            var subFormInstanceIdentifier = tokens.shift();

            // Parent instance object that contains actual yes/no question property
            var parentInstance = $scope.getInstanceByPath('instance.LCPQuestionnaire', subFormInstanceIdentifier);
            var objectName = tokens.shift();

            var needsToClearData = true;

            if (needsToClearData) {
                // When element count is more than 0 then we have to ask confirmation from user whether to delete the data.
                if (elementCount > 0 && !confirm('When changing answer all data under this sub-form will be lost?')){
                    // toke.shift() extracts yes/no question name.
                    // Assing yes value to question
                    parentInstance[objectName] =  changeValueTo;
                    return;
                } else {
                    for (var i = 0; i < dataPaths.length; i++) {
                        var formElementInstance = $scope.getInstanceByPath('instance.LCPQuestionnaire', dataPaths[i]);

                        // For fields where there is only one field and it can be null. Just ignore it.
                        if (!formElementInstance) {
                            continue;
                        }

                        // This if-else is to differentiate just a string field from array or object.
                        if (formElementInstance instanceof Array || !formElementInstance.length) {
                            clearObject(formElementInstance, $scope.isFixedQuestion(dataPaths[i]));
                        } else {
                            var tokens = dataPaths[i].split('.');
                            var objectIdentifier = tokens.shift();
                            var parentObject = $scope.getInstanceByPath('instance.LCPQuestionnaire', objectIdentifier);
                            parentObject[tokens.shift()] = null;
                        }
                    }
                }
            } else {
                // Do nothing.
            }
        };

        $rootScope.TypeOfCombustionPlantFurtherDetails = false;

        $scope.isTypeOfCombustionPlantOther = function (plant) {
            if (plant.PlantDetails.TypeOfCombustionPlant === 'Others') {
                $rootScope.TypeOfCombustionPlantFurtherDetails = true;
            } else {
                $rootScope.TypeOfCombustionPlantFurtherDetails = false;
            }
        };

        //TODO format error message to handle different limits better
        $scope.errorMessages = {
            "required_field" : "This is a required field",
            "unique_abbreviation" : "Please provide a unique abbreviation ",
            "valid_telephone" : "Please enter a valid telephone number (at least 7 digits) ",
            "valid_email" : "Please enter a valid email address ",
            "valid_url" : "Please enter a valid URL ",
            "yes_or_no" : "Please choose yes or no ",
            "number_greater_than_zero" : "Please provide a number greater than 0 ",
            "data_entry_must_be_unique" : "Data entry must be unique ID code ",
            "must_be_less_than" : "Please provide a number less than ",
            "must_be_greater_than" : "Please provide a number greater or equal to ",
            "must_be_percentage" : "Please provide a percentage between 0 and 100 ",
            "whole_number_greater_than_zero" : "Please provide a whole number greater than 0 ",
            "unique_identification_code" : "Please enter a unique identification code ",
            "valid_longitude" : "Please provide a number between -180 and 180",
            "valid_latitude" : "Please provide a number between -90 and 90",
            "positive_decimal" : "Please provide a positive decimal number  ",
            "positive_decimal01" : "Please provide a positive decimal number between 0 and 1",
            "positive_integer" : "Please provide a positive integer ",
            "article_format" : "Please use the edit menu to correct the article format"

        };


        $scope.getErrorMessage = function(errorCode) {
            return $scope.errorMessages[errorCode];
        };

        $scope.showError = function(modelController, errorCode) {
            return modelController.$error[errorCode] && modelController.$invalid
                    && !(errorCode === 'required' && modelController.$error['pattern'] && modelController.$error['pattern'] ==true);// && modelController.$dirty;
        };
        $scope.showErrorIfSubmitted = function(modelController, errorCode, submitted) {
            return submitted && $scope.showError(modelController, errorCode);
        };


        $scope.isGreaterThanZero = function(inputValue) {
            return $scope.submitted == false && ( Number(inputValue) > 0);
        };

        $scope.isPositiveNumber = function(inputValue) {
            var boolean = true ;

            if ( isEmpty (inputValue) ) return false;

            if(!isEmpty(inputValue)  ){
                boolean = $scope.positiveIntegerPattern.test(inputValue);
            }
            return boolean;
        };

        $scope.isPositiveDecimal = function(inputValue) {

            // returns false if empty, or if not decimal(by regex comparison)
            if ( isEmpty (inputValue) ) return false;

            return $scope.positiveDecimalNumberPattern.test(inputValue);

        };
        

        $scope.validDateFormat = function( inputDate){
            // allows empty values for simplicity sake
            if ( isEmpty(inputDate)) return true;
            return $scope.dateFormat.test( inputDate );

        }

        $scope.isDegree = function(inputValue, degrees, submitted) {

            return ($scope.submitted == true && !isEmpty(inputValue) && !(Number(degrees) >= Number(inputValue) && Number(inputValue) >= -Number(degrees)));
        };

        $scope.isRequired = function(inputValue) {
            return  $scope.submitted == true && isEmpty(inputValue);
        };

        $scope.isModalRequired = function(inputValue) {
            var boolean = false;

            if(isEmpty(inputValue)){
                boolean=  true;
            }
            if(inputValue == undefined){
                boolean=  true;

            }
            else{
                if(inputValue.length == 0){
                    boolean=  true;
                }
            }

           /* if(inputValue == null){
                boolean=  true;
            }*/
            return   boolean;


        };


        $scope.checkboxClearInputs = function(plant, checkboxPath, dependingInputs) {
            var tokens1 = checkboxPath.split('.');
            var objectIdentifier1 = tokens1.shift();
            var checkboxObject = $scope.getPlantByPath(plant, objectIdentifier1);
            var property1 = tokens1[tokens1.length-1];
            var checkboxValue = checkboxObject[property1];

            if(checkboxValue == false){
                var inputPathArray = [];
                var isNotEmpty= false;
                var paths = dependingInputs.split(':');

                //Adding checkbox depending inputs to array
                for (var i = 0; i < paths.length; i++) {
                    var tokens2 = paths[i].split('.');
                    var objectIdentifier2 = tokens2.shift();
                    var parentObject = $scope.getPlantByPath(plant, objectIdentifier2);
                    var property = tokens2[tokens2.length-1];
                    var object = parentObject[property];
                    if($scope.positiveDecimalNumberPattern.test(object)){
                        object = object.toString();
                    }
                    //Error handling:  String in numeric field
                    if(object == null){
                        object = "";
                        isNotEmpty = false;
                    }
                    if(object == undefined){
                        object = "";
                        isNotEmpty = true;
                    }
                    inputPathArray.push(object)
                }

                //Is inputs empty
                for (var j = 0; j < inputPathArray.length; j++) {
                    if(inputPathArray[j].length > 0){
                        isNotEmpty = true;
                    }
                }


                if(checkboxValue == false && isNotEmpty){
                    if(confirm("Do you wish to clear data from depending input(s)?")){
                        for (var k = 0; k < paths.length; k++) {
                            var tokens3 = paths[k].split('.');
                            var objectIdentifier3 = tokens3.shift();
                            var parentObject2 = $scope.getPlantByPath(plant, objectIdentifier3);
                            var property2 = tokens3[tokens3.length-1];
                            parentObject2[property2] = "";

                        }
                    }else{
                    //checkbox rollback
                        checkboxObject[property1] = true;
                    }
                    return;
                }
            }
            else{
                var inputPathArray = [];
                var isNotEmpty= false;
                var paths = dependingInputs.split(':');

                //Adding checkbox depending inputs to array
                for (var i = 0; i < paths.length; i++) {
                    var tokens2 = paths[i].split('.');
                    var objectIdentifier2 = tokens2.shift();
                    var parentObject = $scope.getPlantByPath(plant, objectIdentifier2);
                    var property = tokens2[tokens2.length-1];
                    var object = parentObject[property];
                    if($scope.positiveDecimalNumberPattern.test(object)){
                        object = object.toString();
                    }
                    //Error handling:  String in numeric field
                    if(object == undefined){
                        object = "";
                        isNotEmpty = true;
                    }
                    inputPathArray.push(object)
                }

                //Is inputs empty
                for (var j = 0; j < inputPathArray.length; j++) {
                    if(inputPathArray[j].length > 0){
                        isNotEmpty = true;
                    }
                }

                if (tokens1 == 'Refineries' && checkboxValue == true && isNotEmpty){

                    if(confirm("Do you wish to clear data from depending input(s)?")){
                        for (var k = 0; k < paths.length; k++) {
                            var tokens3 = paths[k].split('.');
                            var objectIdentifier3 = tokens3.shift();
                            var parentObject2 = $scope.getPlantByPath(plant, objectIdentifier3);
                            var property2 = tokens3[tokens3.length-1];
                            parentObject2[property2] = "";

                        }
                    }else{
                        //checkbox rollback
                        checkboxObject[property1] = true;
                    }
                    return;
                }
            }
        }    ;

        $scope.isDesulphurizationRateEmpty = function (desulphurisation) {
            if (desulphurisation == null || desulphurisation.Months==null || desulphurisation.Months.Month==null  || desulphurisation.Months.Month.length==1) {
                return true;
            }
            if(desulphurisation.Months.Month.isArray){
            desulphurisation.Months.Month.forEach(function (element) {
                if (element.DesulphurisationRate == null) {
                    return true;
                }
            }, this);
        }
            return false;
        };

        $scope.isSulphurContentEmpty = function (desulphurisation) {
            if (desulphurisation == null || desulphurisation.Months==null || desulphurisation.Months.Month==null  || desulphurisation.Months.Month.length==1) {
                return true;
            }

            if(desulphurisation.Months.Month.isArray){                
            desulphurisation.Months.Month.forEach(function (element) {
                if (element.SulphurContent == null) {
                    return true;
                }

            }, this);
        }
            return false;
        };
        $scope.isTechnicalJustificationEmpty = function (desulphurisation) {
            if (desulphurisation == null || desulphurisation.Months==null || desulphurisation.Months.Month==null  || desulphurisation.Months.Month.length==1) {
                return true;
            }
            if(desulphurisation.Months.Month.isArray){
                
            desulphurisation.Months.Month.forEach(function (element) {

                if (element.TechnicalJustification == null || element.TechnicalJustification == '') {
                    return true;
                }

            }, this);
        }
            return false;
        };
        
    });
    function isEmpty(value){
        // returns true on undefined, empty array, empty string
        if(value === 0){
            return false;
        }
        else{
            return (!value || value === undefined || value.length === 0 || value === "" );
        }
    }



    // get instance data and save instance data
    app.factory('dataRepository', function($rootScope, $http) {
        var codeLists = {};
        //var lcpVocabularySetBaseUri = 'http://test.tripledev.ee/datadict/vocabulary/lcp/';
        //var lcpVocabularySetBaseUri = DD_VOCABULARY_BASE_URI + 'habides/';
     
     
        var EPRTRandlLCPVocabularySetBaseUri = DD_VOCABULARY_BASE_URI + 'EPRTRandLCP/';
        var EPRTRandLCPvocabularies =['CombustionPlantCategoryValue', 'CountryCodeValue', 'EPRTRPollutantCodeValue', 'FuelInputValue',
         'LCPPollutantCodeValue', 'MediumCodeValue', 'MethodClassificationValue', 'MethodCodeValue', 'MonthValue', 
         'OtherGaseousFuelValue', 'OtherSolidFuelValue', 'ReasonValue', 'UnitCodeValue', 'WasteClassificationValue',
          'WasteTreatmentValue'];
        var EPRTRandLCPvocabularyIdentifiersInCode = ['CombustionPlantCategoryValue', 'CountryCodeValue', 'EPRTRPollutantCodeValue', 'FuelInputValue',
         'LCPPollutantCodeValue', 'MediumCodeValue', 'MethodClassificationValue', 'MethodCodeValue', 'MonthValue', 
         'OtherGaseousFuelValue', 'OtherSolidFuelValue', 'ReasonValue', 'UnitCodeValue', 'WasteClassificationValue',
          'WasteTreatmentValue'];
        
      
  var lcpVocabularySetBaseUri = DD_VOCABULARY_BASE_URI + 'lcp/';
        var lcpVocabularies = ['lcpcountries','plantstatus','sectors'];
        var lcpVocabularyIdentifiersInCode = ['countries', 'status', 'sectors'];

        var commonVocabularySetBaseUri = DD_VOCABULARY_BASE_URI + 'common/';

        //define undefined members, i dont know if this is really necessary!!!
        codeLists.LCPCodelists = {};
        codeLists.OldLCPCodelists={};
        codeLists.CombustionPlantCodeLists={};
        codeLists.DerogationValueCodeLists={};
        codeLists.OtherSolidFuelCodeLists={};
        codeLists.OtherGasesousFuelCodeLists={};
        codeLists.MonthValueCodeLists={};
        codeLists.MonthlyDesulphurisation={};

        var regionCodeLists = {};
        for (var i = 0; i < EPRTRandLCPvocabularies.length; i++){
            codeLists.LCPCodelists[EPRTRandLCPvocabularyIdentifiersInCode[i]] = {};
        }
        for (var i = 0; i < lcpVocabularies.length; i++){
            codeLists.OldLCPCodelists[lcpVocabularyIdentifiersInCode[i]] = {};
        }
        return {
            getInstance: function() {
                var url = null;
                if (fileId){
                    url = getWebQUrl("/download/converted_user_file");
                }
				else {
                    url = "lcp-instance-test.json";
				}
                return $http.get(url, {tracker : $rootScope.loadingTracker});
            },
            saveInstance: function (data) {
                var url = getWebQUrl("/saveXml");
                fixUndefined(data);
                return $http.post(url, data, {tracker : $rootScope.loadingTracker});
            },
            getCodeList: function() {
                return codeLists;
            },
            loadCodeList: function(language) {
                //finds file in project folder
                var defaultlanguage = 'en';
                var currentLanguage = !language? defaultlanguage : language;

                for (var i = 0; i < EPRTRandLCPvocabularies.length; i++) {
                    var url = EPRTRandlLCPVocabularySetBaseUri + EPRTRandLCPvocabularies[i] + '/json?lang=' + currentLanguage;

                    if ($rootScope.isIE9 || window.isIE9){
                        url = baseUri + '/restProxy?uri=' + encodeURIComponent(url);
                    }

                    $http.get(url, {tracker: $rootScope.loadingTracker})
                            .error(function(data, status, headers, config){
                                alert("Failed to read code lists. Data = " +  data + ", status = " + status);})
                            .success((function(i){return function (newCodeList) {
                        angular.copy(newCodeList, codeLists.LCPCodelists[EPRTRandLCPvocabularyIdentifiersInCode[i]]);
                        ////console.log("received " + vocabularyIdentifiersInCode[i]);
                    }})(i));
                } 
            }, 
            loadOldLCPCodeList: function(language) {
                //finds file in project folder
                var defaultlanguage = 'en';
                var currentLanguage = !language? defaultlanguage : language;

                for (var i = 0; i < lcpVocabularies.length; i++) {
                    var url = lcpVocabularySetBaseUri + lcpVocabularies[i] + '/json?lang=' + currentLanguage;

                    if ($rootScope.isIE9 || window.isIE9){
                        url = baseUri + '/restProxy?uri=' + encodeURIComponent(url);
                    }

                    $http.get(url, {tracker: $rootScope.loadingTracker})
                            .error(function(data, status, headers, config){
                                alert("Failed to read code lists. Data = " +  data + ", status = " + status);})
                            .success((function(i){return function (newCodeList) {
                                console.log("newCodeList "+newCodeList);
                        angular.copy(newCodeList, codeLists.OldLCPCodelists[lcpVocabularyIdentifiersInCode[i]]);
                        ////console.log("received " + vocabularyIdentifiersInCode[i]);
                    }})(i));
                } 
            }, 
             loadCombustionPlantCodeList: function(language){
                // we do not need the for each of the above loadCodeList method, since in the above , it has to make seperate calls
                // for each vocabulary, whereas we do not have to.
                var defaultlanguage = 'en';
                var currentLanguage = !language? defaultlanguage : language;
                var url = 'http://dd.eionet.europa.eu/vocabulary/EPRTRandLCP/CombustionPlantCategoryValue/json';
                $http.get(url, {tracker: $rootScope.loadingTracker})
                .error(function(data, status, headers, config){
                    alert("Failed to read code lists. Data = " +  data + ", status = " + status);})
                .success( function (newCodeList) {
            angular.copy(newCodeList, codeLists.CombustionPlantCodeLists);
            ////console.log("received " + vocabularyIdentifiersInCode[i]);
                  });
            },
            loadDerogationValueCodeList: function(language){
                // we do not need the for each of the above loadCodeList method, since in the above , it has to make seperate calls
                // for each vocabulary, whereas we do not have to.
                var defaultlanguage = 'en';
                var currentLanguage = !language? defaultlanguage : language;
                var url = 'http://dd.eionet.europa.eu/vocabulary/euregistryonindustrialsites/DerogationValue/json';
                $http.get(url, {tracker: $rootScope.loadingTracker})
                .error(function(data, status, headers, config){
                    alert("Failed to read code lists. Data = " +  data + ", status = " + status);})
                .success( function (newCodeList) {
            angular.copy(newCodeList, codeLists.DerogationValueCodeLists);
            ////console.log("received " + vocabularyIdentifiersInCode[i]);
                  });
            },
            loadOtherSolidFuelCodeList: function(language){
                // we do not need the for each of the above loadCodeList method, since in the above , it has to make seperate calls
                // for each vocabulary, whereas we do not have to.
                var defaultlanguage = 'en';
                var currentLanguage = !language? defaultlanguage : language;
                var url = 'http://dd.eionet.europa.eu/vocabulary/EPRTRandLCP/OtherSolidFuelValue/json';
                $http.get(url, {tracker: $rootScope.loadingTracker})
                .error(function(data, status, headers, config){
                    alert("Failed to read code lists. Data = " +  data + ", status = " + status);})
                .success( function (newCodeList) {
                    //Push "Other" value to the end of the Array
                    var otherElement ={};
                    newCodeList.concepts.forEach(function(element) {
                        if(element['@id']=='Other'){
                            var OtherElementIndex = newCodeList.concepts.indexOf(element);
                            newCodeList.concepts.splice(OtherElementIndex,1);
                             Object.assign(otherElement,element);
                        }
                    }, this);
                    newCodeList.concepts.push(otherElement);
            angular.copy(newCodeList, codeLists.OtherSolidFuelCodeLists);
                  });
            },
            loadOtherGasesousFuelCodeList: function(language){
                // we do not need the for each of the above loadCodeList method, since in the above , it has to make seperate calls
                // for each vocabulary, whereas we do not have to.
                var defaultlanguage = 'en';
                var currentLanguage = !language? defaultlanguage : language;
                var url = 'http://dd.eionet.europa.eu/vocabulary/EPRTRandLCP/OtherGaseousFuelValue/json';
                $http.get(url, {tracker: $rootScope.loadingTracker})
                .error(function(data, status, headers, config){
                    alert("Failed to read code lists. Data = " +  data + ", status = " + status);})
                .success( function (newCodeList) {
                        //Push "Other" value to the end of the Array
                        var otherElement ={};
                        newCodeList.concepts.forEach(function(element) {
                            if(element['@id']=='Other'){
                                var OtherElementIndex = newCodeList.concepts.indexOf(element);
                                newCodeList.concepts.splice(OtherElementIndex,1);
                                 Object.assign(otherElement,element);
                            }
                        }, this);
                        newCodeList.concepts.push(otherElement);
            angular.copy(newCodeList, codeLists.OtherGasesousFuelCodeLists);
            ////console.log("received " + vocabularyIdentifiersInCode[i]);
                  });
            },
            loadMonthValueCodeList: function(language){
                // we do not need the for each of the above loadCodeList method, since in the above , it has to make seperate calls
                // for each vocabulary, whereas we do not have to.
                var defaultlanguage = 'en';
                var currentLanguage = !language? defaultlanguage : language;
                var url = 'http://dd.eionet.europa.eu/vocabulary/EPRTRandLCP/MonthValue/json';
                $http.get(url, {tracker: $rootScope.loadingTracker})
                .error(function(data, status, headers, config){
                    alert("Failed to read code lists. Data = " +  data + ", status = " + status);})
                .success( function (newCodeList) {
            angular.copy(newCodeList, codeLists.MonthValueCodeLists);
            ////console.log("received " + vocabularyIdentifiersInCode[i]);
            angular.forEach(codeLists.MonthValueCodeLists.concepts, function(value, key){
                          codeLists.MonthlyDesulphurisation[key]={
                    "DesulphurisationRate": '',
                    "MonthValue":value.prefLabel[0]['@value'],
                    "SulphurContent": '',
                    "TechnicalJustification": ''
                    };
                });
            });
        },
       
            loadRegionsCodelist: function(country) {
                var url = DD_VOCABULARY_BASE_URI + "common/nuts/json?id=" + country;
                if ($rootScope.isIE9 || window.isIE9){
                    url = baseUri + '/restProxy?uri=' + encodeURIComponent(url);
                }
                //console.log(url);
                $http.get(url, {tracker: $rootScope.loadingTracker})
                        .error(function(data, status, headers, config){alert("Failed to read regions code lists.");})
                        .success(function (newCodeList) {
                            angular.copy(newCodeList, regionCodeLists);
                            if(regionCodeLists.concepts.length == 0){
                                var url = DD_VOCABULARY_BASE_URI + "lcp/lcpcountries/json?id=" + country;
                                if ($rootScope.isIE9 || window.isIE9){
                                    url = baseUri + '/restProxy?uri=' + encodeURIComponent(url);
                                }
                                $http.get(url, {tracker: $rootScope.loadingTracker})
                                    .error(function(data, status, headers, config){alert("Failed to read regions code lists.");})
                                    .success(function (plantDetailsOtherSectorFieldsViewnewCodeList) {
                                    angular.copy(newCodeList, regionCodeLists);
                                });
                            }
                        });
                return regionCodeLists;
            },
            getEmptyInstance: function() {
                var url = 'lcp-instance-empty.xml?format=json';
                return $http.get(url, {tracker : $rootScope.loadingTracker});
            },
            loadInstanceInfo: function (data) {
                var url = getWebQUrl("/file/info");
                return $http.get(url, data, {tracker : $rootScope.loadingTracker});
            }
        }
    });

    // new
    app.filter('offset', function() {
        return function(input, start) {
            if (!input || !(input instanceof Array)) {
                return;
            }
            start = parseInt(start, 10);
            return input.slice(start);
        };
    });

  /**  app.filter('formatDerogation', function () {
        return function (x) {
            var result = "";
            if (x != null &&x.isArray) {
                x.forEach(function (entry) {
                    result += entry;
                    result += '\n';
                });
            }
            return result;
        };
    });
     **/
    app.controller('ModalCtrl', function ($scope, $rootScope, $modal, $http) {
        //saves Main form validation stage
        $scope.mainFormSubmitted = $scope.submitted;
        $scope.plant;
        $scope.originalPlant;

        $scope.submitted = false;
        $scope.editBoolean = false;
        /*$scope.edit = function (plant){
            $scope.editBoolean = true;
            $scope.plant= plant;
            $scope.open('lg');
        }*/
        $scope.add = function (){
            $scope.submitted = false;
            $scope.editBoolean = false;
            $scope.plant = null;
            $scope.open('lg');
        }
        $rootScope.$watch('selectedPlant', function(newValue, oldValue) {
            if (newValue && newValue != null ){
                $scope.submitted = true;
                $scope.editBoolean = true;
                $scope.originalPlant =  newValue;
                $scope.plant = angular.copy(newValue);
                $rootScope.selectedPlant = null;
                $scope.open('lg', $rootScope.modalPageCaseId);
            }
        });
        $scope.openAdd = function(){
            
            $rootScope.modalPageCaseId = "ListOfPlants";
            $rootScope.selectedPlant = null;
            $scope.open('lg','ListOfPlants');
        }
        $scope.loadDataFromEPRTR = function(plant) {
            console.log('loadDataFromEPRTR function invoked');
            var countryCode = $scope.instance.LCPQuestionnaire.BasicData.MemberState;
            if (countryCode && countryCode.length == 2 && plant ) {

                var eprtrCountryCode = countryCode === "GB" ? "UK" : countryCode === "GR" ? "EL" : countryCode;

                var url = "http://semantic.eea.europa.eu/sparql?format=application/json&query=";
                var sparql = "PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#> " +
                        " PREFIX cr: <http://cr.eionet.europa.eu/ontologies/contreg.rdf#> " +
                        " PREFIX prtr: <http://prtr.ec.europa.eu/rdf/schema.rdf#> " +
                        " PREFIX geo: <http://www.w3.org/2003/01/geo/wgs84_pos#> " +
                        " SELECT ?countryCode ?NationalID ?facilityID ?facilityName ?streetName ?buildingNumber ?postalCode ?city ?lat ?long ?reportingYear" +
                        " WHERE { ?facility a prtr:Facility ; " +
                        " prtr:facilityID ?facilityID ; " +
                        " prtr:facilityName ?facilityName ; " +
                        " prtr:streetName ?streetName; " +
                        "prtr:buildingNumber  ?buildingNumber ; "+
                        " prtr:postalCode  ?postalCode ; " +
                        " prtr:city ?city ; " +
                        " geo:lat ?lat ; " +
                        " geo:long ?long ; " +
                        " prtr:latestReport ?latestreport ;" +
                        " prtr:inCountry ?inCountry . " +
                        " ?inCountry prtr:code ?countryCode . " +
                        " ?latestreport prtr:nationalID ?NationalID ;" +
                        " prtr:reportingYear ?reportingYear." +
                        " FILTER (?countryCode = '" + eprtrCountryCode + "' and UCASE(?NationalID) = UCASE('" + plant.EPRTRNationalId + "' ) ) } ORDER BY DESC(?reportingYear) LIMIT 1";
                url = baseUri + '/restProxy?uri=' + encodeURIComponent(url + encodeURIComponent(sparql));
                console.log('url for sparql eprtr data is:'+url);
                $http.get(url, {tracker : $rootScope.loadingTracker})
                        .error(function(){alert("Failed to read data from E-PRTR.");})
                        .success(function(eprtrData) {
                            if (eprtrData.results.bindings.length > 0) {
                            var facility = eprtrData.results.bindings[0];
                            if (confirm("The system found the following facility: " + facility.facilityName.value + ", " + facility.streetName.value + ", " + facility.postalCode.value +
                                    ", "  + facility.city.value + ". \n\n Do you want to use the data on plant level?" )) {
                                    if (!plant.PlantLocation) plant.PlantLocation = {};
                                    if (!plant.GeographicalCoordinate) plant.GeographicalCoordinate = {};
                                    plant.PlantLocation.Address1 = facility.streetName.value;
                                    if (!isEmpty(facility.buildingNumber.value)) {
                                        plant.PlantLocation.Address1 += " " + facility.buildingNumber.value;
                                    }
                                    plant.PlantLocation.City =facility.city.value;
                                    plant.PlantLocation.PostalCode = facility.postalCode.value;
                                    plant.PlantLocation.BuildingNumber = facility.buildingNumber.value;
                                    plant.GeographicalCoordinate.Longitude = facility.long.value;
                                    plant.GeographicalCoordinate.Latitude = facility.lat.value;
                                    plant.FacilityName = facility.facilityName.value;
                               }
                            }
                            else {
                                alert("The system could not find any facility with NationalID=" + plant.EPRTRNationalId);
                            }
                        });
            }
            else {
                alert("Member state is not selected on Basic Data form!");
            }
        };
        //edit(
        $scope.open = function (size,modalPageId) {
            //console.log(modalPageId);
            //console.log($rootScope.modalPageCaseId== undefined);
            //console.log($rootScope.modalPageCaseId=="ListOfPlants");
            //console.log($rootScope.modalPageCaseId=="PlantDetails");
            var modalInstance;
            //For adding new plant
            if(modalPageId == undefined){
 //               if ( $scope.instance.LCPQuestionnaire.BasicData.MemberState!=null )
//{               
                modalInstance = $modal.open({

                    templateUrl: 'ListOfPlantModalContent.html',
                    controller: 'ListOfPlantsModalInstanceCtrl',
                    size: size,
                    scope: $scope,
                    windowClass: 'app-modal-window',
                    resolve: {
                        plant: function () {
                            return  $scope.plant;
                        }
                    }

                });
            //   }else{
             //      alert("Please fill in the Member State from Basic Info first.");
             //      return;
             //  }
               
            }
            //For editing plant
            if(modalPageId == "ListOfPlants"){
                modalInstance = $modal.open({

                    templateUrl: 'ListOfPlantModalContent.html',
                    controller: 'ListOfPlantsModalInstanceCtrl',
                    size: size,
                    scope: $scope,
                    windowClass: 'app-modal-window',
                    resolve: {
                        plant: function () {
                            return  $scope.plant;
                        }
                    }

                });
            }
            if(modalPageId == "PlantDetails"){
                 modalInstance = $modal.open({

                    templateUrl: 'PlantDetailsModalContent.html',
                    controller: 'PlantDetailsModalInstanceCtrl',
                    size: size,
                    scope: $scope,
                    windowClass: 'app-modal-window',
                    resolve: {
                        plant: function () {
                            return  $scope.plant;
                        }
                    }

                });
            }
            if(modalPageId=="TotalEmissionsToAir"){
                modalInstance = $modal.open({

                    templateUrl: 'TotalEmissionsToAirModalContent.html',
                    controller: 'TotalEmissionsToAirModalInstanceCtrl',
                    size: size,
                    scope: $scope,
                    windowClass: 'app-modal-window',
                    resolve: {
                        plant: function () {
                            return  $scope.plant;
                        }
                    }

                });
            }
            if(modalPageId=="EnergyInput"){
                modalInstance = $modal.open({

                    templateUrl: 'EnergyInputModalContent.html',
                    controller: 'EnergyInputModalInstanceCtrl',
                    size: size,
                    scope: $scope,
                    windowClass: 'app-modal-window',
                    resolve: {
                        plant: function () {
                            return  $scope.plant;
                        }
                    }

                });
            }
            if(modalPageId=="Desulphurisation"){
                modalInstance = $modal.open({

                    templateUrl: 'DesulphurisationModalContent.html',
                    controller: 'DesulphurisationModalInstanceCtrl',
                    size: size,
                    scope: $scope,
                    windowClass: 'app-modal-window',
                    resolve: {
                        plant: function () {
                            return  $scope.plant;
                        }
                    }

                });
            }
            if(modalPageId=="UsefulHeat"){
                modalInstance = $modal.open({

                    templateUrl: 'UsefulHeatModalContent.html',
                    controller: 'UsefulHeatModalInstanceCtrl',
                    size: size,
                    scope: $scope,
                    windowClass: 'app-modal-window',
                    resolve: {
                        plant: function () {
                            return  $scope.plant;
                        }
                    }

                });
            }

            modalInstance.result.then(function (selectedItem) {
                $scope.selected = selectedItem;
            }, function () {
                //$log.info('Modal dismissed at: ' + new Date());
            });
        };
    });

    app.controller('ListOfPlantsModalInstanceCtrl', function ($rootScope, $scope, $modalInstance, plant,dataRepository) {
        var edit = false;

        if(plant != undefined){
            edit = true;
        }

        if (JSON.stringify( $scope.regionsCodelist ) === "{}")  {

            if ( $scope.instance.LCPQuestionnaire.BasicData.MemberState )
                $scope.regionsCodelist = dataRepository.loadRegionsCodelist($scope.instance.LCPQuestionnaire.BasicData.MemberState);
            else {
                alert("Please fill in the Member State from Basic Info first.");
                $scope.submitted = $scope.mainFormSubmitted;
             //   $modalInstance.dismiss('cancel');
                $modalInstance.close();
            }
        }

        $scope.ok = function (plant) {

            $scope.submitted = true;
            if(plant != undefined){
                if(plant.PlantName != null && plant.GeographicalCoordinate.Longitude != null &&
                        (180 >= plant.GeographicalCoordinate.Longitude && plant.GeographicalCoordinate.Longitude >= -180)  &&
                        plant.GeographicalCoordinate.Latitude != null && (90 >= plant.GeographicalCoordinate.Latitude && plant.GeographicalCoordinate.Latitude >= -90)){
                    if(!edit){

                        if ( plant.PlantLocation == null ) plant.PlantLocation = {} ;

                        var lastPlant = $scope.addItem('LCPQuestionnaire.ListOfPlants.Plant');
                        var promise = $scope.getNextPlantId () ;
                        // using $q promise API, to ask the server first for id collisions.
                        promise.then ( function ( plantid ) {

                            lastPlant.PlantId = plantid ;
                            lastPlant.PlantName =  plant.PlantName;
                            lastPlant.EPRTRNationalId =  plant.EPRTRNationalId;
                            lastPlant.PlantLocation.StreetName =  plant.PlantLocation.StreetName;
                         //   lastPlant.PlantLocation.Address2 =  plant.PlantLocation.Address2;
                            lastPlant.PlantLocation.City =  plant.PlantLocation.City;
                            lastPlant.PlantLocation.Region =  plant.PlantLocation.Region;
                            lastPlant.PlantLocation.PostalCode =  plant.PlantLocation.PostalCode;
                            lastPlant.PlantLocation.BuildingNumber =  plant.PlantLocation.BuildingNumber;
                            lastPlant.PlantLocation.CountryCode =  $scope.instance.LCPQuestionnaire.BasicData.MemberState;
                            lastPlant.GeographicalCoordinate.Longitude =  plant.GeographicalCoordinate.Longitude;
                            lastPlant.GeographicalCoordinate.Latitude =  plant.GeographicalCoordinate.Latitude;
                            lastPlant.FacilityName =  plant.FacilityName;
                            lastPlant.Comments =  plant.Comments;

                            $rootScope.$broadcast('updateFilter');

                            //load Main form validation stage
                            $scope.submitted = $scope.mainFormSubmitted;
                            $scope.saveInstance();
                             $modalInstance.close(plant);

                        })

                    }
                    else{
                        var lastPlant = $scope.originalPlant;
                        lastPlant.PlantName =  plant.PlantName;
                        lastPlant.EPRTRNationalId =  plant.EPRTRNationalId;
                        lastPlant.PlantLocation.StreetName =  plant.PlantLocation.StreetName;
                        //lastPlant.PlantLocation.Address2 =  plant.PlantLocation.Address2;
                        lastPlant.PlantLocation.City =  plant.PlantLocation.City;
                        lastPlant.PlantLocation.Region =  plant.PlantLocation.Region;
                        lastPlant.PlantLocation.BuildingNumber =  plant.PlantLocation.BuildingNumber;
                        lastPlant.PlantLocation.PostalCode =  plant.PlantLocation.PostalCode;
                        lastPlant.PlantLocation.CountryCode = $scope.instance.LCPQuestionnaire.BasicData.MemberState;
                        lastPlant.GeographicalCoordinate.Longitude =  plant.GeographicalCoordinate.Longitude;
                        lastPlant.GeographicalCoordinate.Latitude =  plant.GeographicalCoordinate.Latitude;
                        lastPlant.FacilityName =  plant.FacilityName;
                        lastPlant.Comments =  plant.Comments;

                        $rootScope.$broadcast('updateFilter');

                        //load Main form validation stage
                        $scope.submitted = $scope.mainFormSubmitted;
                            $scope.saveInstance();
                                             $modalInstance.close(plant);


                     }

                } else{
                     $scope.submitted = true;
                     alert("Please fill in all mandatory fields!");
                 }
            } else{
                 $scope.submitted = true;
                 alert("Please fill in all mandatory fields!");
             }

        };
        $scope.saveAndAdd =  function(plant){
            $scope.ok(plant);
            saveInstance();
        }
        $scope.cancel = function () {
            //load Main form validation stage
            $scope.submitted = $scope.mainFormSubmitted;
            $modalInstance.dismiss('cancel');
        };
    });
    app.controller('PlantDetailsModalInstanceCtrl', function ($rootScope, $filter, $scope, $modalInstance, plant) {
        $scope.ok = function (plant) {
            if (!$scope.modalPlantDetails.$invalid) {
                var lastPlant = $scope.originalPlant;
                lastPlant.PlantDetails.MWth =  plant.PlantDetails.MWth;
                lastPlant.PlantDetails.DateOfStartOfOperation =  plant.PlantDetails.DateOfStartOfOperation;
                lastPlant.PlantDetails.Refineries =  $filter('lowercase')(plant.PlantDetails.Refineries);
                lastPlant.PlantDetails.OtherSector =  plant.PlantDetails.OtherSector;
                lastPlant.PlantDetails.OperatingHours =  plant.PlantDetails.OperatingHours;                
                lastPlant.PlantDetails.Comments =  plant.PlantDetails.Comments;
                
                lastPlant.PlantDetails.TypeOfCombustionPlant = plant.PlantDetails.TypeOfCombustionPlant;
                lastPlant.PlantDetails.TypeOfCombustionPlantFurtherDetails = plant.PlantDetails.TypeOfCombustionPlantFurtherDetails;
                lastPlant.PlantDetails.Derogation = plant.PlantDetails.Derogation;
    

                $rootScope.$broadcast('updateFilter');

                //load Main form validation stage
                $scope.submitted = $scope.mainFormSubmitted;
                $scope.modalPlantDetails.$setPristine(true);
                $modalInstance.close(plant);
            }
            else{
                $scope.submitted = true;
                alert("Please fill in all mandatory fields! ");
            }


        }

        $scope.cancel = function () {
            //load Main form validation stage
            $scope.submitted = $scope.mainFormSubmitted;
            $modalInstance.dismiss('cancel');
        };
    });

    app.controller('TotalEmissionsToAirModalInstanceCtrl', function ($rootScope, $scope, $modalInstance, plant) {

        $scope.ok = function (plant) {
            if (!$scope.modalTotalEmissionsToAir.$invalid) {
                var lastPlant = $scope.originalPlant;

                lastPlant.EnergyInputAndTotalEmissionsToAir.TotalEmissionsToAir.SO2 =  plant.EnergyInputAndTotalEmissionsToAir.TotalEmissionsToAir.SO2;
                lastPlant.EnergyInputAndTotalEmissionsToAir.TotalEmissionsToAir.NOx =  plant.EnergyInputAndTotalEmissionsToAir.TotalEmissionsToAir.NOx;
                lastPlant.EnergyInputAndTotalEmissionsToAir.TotalEmissionsToAir.TSP =  plant.EnergyInputAndTotalEmissionsToAir.TotalEmissionsToAir.TSP;

                $rootScope.$broadcast('updateFilter');

                //load Main form validation stage
                $scope.submitted = $scope.mainFormSubmitted;
                $scope.modalTotalEmissionsToAir.$setPristine(true);
                $modalInstance.close(plant);
            }
            else{
                $scope.submitted = true;
                alert("Please fill in all mandatory fields! ");
            }


        }

        $scope.cancel = function () {
            //load Main form validation stage
            $scope.submitted = $scope.mainFormSubmitted;
            $modalInstance.dismiss('cancel');
        };
    });
app.controller('EnergyInputModalInstanceCtrl', function ($rootScope, $scope, $modalInstance, plant) {

        $scope.ok = function (plant) {
            if (!$scope.modalEnergyInput.$invalid) {
                var lastPlant = $scope.originalPlant;

                lastPlant.EnergyInputAndTotalEmissionsToAir.EnergyInput.Biomass =  plant.EnergyInputAndTotalEmissionsToAir.EnergyInput.Biomass;
                lastPlant.EnergyInputAndTotalEmissionsToAir.EnergyInput.Biomass =  plant.EnergyInputAndTotalEmissionsToAir.EnergyInput.Biomass;  
                lastPlant.EnergyInputAndTotalEmissionsToAir.EnergyInput.Coal =  plant.EnergyInputAndTotalEmissionsToAir.EnergyInput.Coal;      
                lastPlant.EnergyInputAndTotalEmissionsToAir.EnergyInput.Lignite =  plant.EnergyInputAndTotalEmissionsToAir.EnergyInput.Lignite;      
                lastPlant.EnergyInputAndTotalEmissionsToAir.EnergyInput.Peat =  plant.EnergyInputAndTotalEmissionsToAir.EnergyInput.Peat;      
                lastPlant.EnergyInputAndTotalEmissionsToAir.EnergyInput.OtherSolidFuels.Category =  plant.EnergyInputAndTotalEmissionsToAir.EnergyInput.OtherSolidFuels.Category;
                lastPlant.EnergyInputAndTotalEmissionsToAir.EnergyInput.OtherSolidFuels.Value =  plant.EnergyInputAndTotalEmissionsToAir.EnergyInput.OtherSolidFuels.Value;
                lastPlant.EnergyInputAndTotalEmissionsToAir.EnergyInput.LiquidFuels =  plant.EnergyInputAndTotalEmissionsToAir.EnergyInput.LiquidFuels;
                lastPlant.EnergyInputAndTotalEmissionsToAir.EnergyInput.NaturalGas =  plant.EnergyInputAndTotalEmissionsToAir.EnergyInput.NaturalGas;
                lastPlant.EnergyInputAndTotalEmissionsToAir.EnergyInput.OtherGases.Category =  plant.EnergyInputAndTotalEmissionsToAir.EnergyInput.OtherGases.Category;
                lastPlant.EnergyInputAndTotalEmissionsToAir.EnergyInput.OtherGases.Value =  plant.EnergyInputAndTotalEmissionsToAir.EnergyInput.OtherGases.Value;

                $rootScope.$broadcast('updateFilter');

                //load Main form validation stage
                $scope.submitted = $scope.mainFormSubmitted;
                $scope.modalEnergyInput.$setPristine(true);
                $modalInstance.close(plant);
            }
            else{
                $scope.submitted = true;
                alert("Please fill in all mandatory fields! ");
            }


        }

        $scope.cancel = function () {
            //load Main form validation stage
            $scope.submitted = $scope.mainFormSubmitted;
            $modalInstance.dismiss('cancel');
        };
    });

    
            app.controller('DesulphurisationModalInstanceCtrl', function ($rootScope, $scope, $modalInstance, plant) {

                //We check if Month is an array and if not initialize it as an array in order to then fill it below.
                if(plant.Desulphurisation.Months==null || plant.Desulphurisation.Months.Month==null  || plant.Desulphurisation.Months.Month.constructor === Object || plant.Desulphurisation.Months.Month.length==1) {
                    plant.Desulphurisation.Months.Month=[];
                //If Months Empty , initialize them before the modal
                angular.forEach($scope.codeList.MonthlyDesulphurisation, function (value, key) {
                    if (plant.Desulphurisation.Months.Month[key]==null){
                         plant.Desulphurisation.Months.Month.push({
                                "MonthValue": value.MonthValue,
                                "DesulphurisationRate": null,
                                "SulphurContent": null,
                                "TechnicalJustification": null
                            });
                    }

                })
                }
               

                $scope.ok = function (plant) {
                    if (!$scope.modalDesulphurisation.$invalid) {
                        var lastPlant = $scope.originalPlant;
                        angular.forEach($scope.codeList.MonthlyDesulphurisation, function (value, key) {
                     /**       plant.Desulphurisation.Months.Month.push({
                                "MonthValue": value.MonthValue,
                                "DesulphurisationRate": value.DesulphurisationRate,
                                "SulphurContent": value.SulphurContent,
                                "TechnicalJustification": value.TechnicalJustification
                            });
                        **/
                        })

                        lastPlant.Desulphurisation = plant.Desulphurisation;
                        $rootScope.$broadcast('updateFilter');
                        //load Main form validation stage
                        $scope.submitted = $scope.mainFormSubmitted;
                        $scope.modalDesulphurisation.$setPristine(true);
                        $modalInstance.close(plant);

                    }
                    else {
                        $scope.submitted = true;
                        alert("Please fill in all mandatory fields! ");
                    }


                }

                $scope.cancel = function () {
                    //load Main form validation stage
                    $scope.submitted = $scope.mainFormSubmitted;
                    $modalInstance.dismiss('cancel');
                };
            });

            app.controller('UsefulHeatModalInstanceCtrl', function ($rootScope, $scope, $modalInstance, plant) {
                
                        $scope.ok = function (plant) {
                            if (!$scope.modalUsefulHeat.$invalid) {
                                var lastPlant = $scope.originalPlant;
                
                                lastPlant.UsefulHeat.UsefulHeatProportion =  plant.UsefulHeat.UsefulHeatProportion;
                              
                                $rootScope.$broadcast('updateFilter');
                
                                //load Main form validation stage
                                $scope.submitted = $scope.mainFormSubmitted;
                                $scope.modalUsefulHeat.$setPristine(true);
                                $modalInstance.close(plant);
                            }
                            else{
                                $scope.submitted = true;
                                alert("Please fill in all mandatory fields! ");
                            }
                
                
                        }
                
                        $scope.cancel = function () {
                            //load Main form validation stage
                            $scope.submitted = $scope.mainFormSubmitted;
                            $modalInstance.dismiss('cancel');
                        };
                    });

  
    app.filter('true_false', function() {
        return function(text, length, end) {
            if (text && (text === true || text === 'TRUE')) {
                return 'Yes';
            }
            return 'No';
        }
    });

    app.controller("PaginationCtrl", function($scope, $filter, $rootScope, $modal) {



        var orderBy = $filter('orderBy');
        /*
            if (!angular.isArray($scope.instance.LCPQuestionnaire.ListOfPlants)){
                $scope.instance.LCPQuestionnaire.ListOfPlants = [$scope.instance.LCPQuestionnaire.ListOfPlants];
            }
        */


        $scope.itemsPerPage = 50;
        $scope.currentPage = 0;
        $scope.maxPages = 15;
        $scope.searchText = "";
        $scope.filteredItems = [];
        $scope.predicateAttribute = 'PlantId';
        $scope.showMessage = false;
        $scope.predicate = function(item) {
            return item[$scope.predicateAttribute];
        }
        $scope.reverse = false;



        $scope.order = function(attribute, order) {
            $scope.predicateAttribute = attribute;
            $scope.reverse = order;
            $scope.filteredItems = orderBy($scope.filteredItems, $scope.predicate, $scope.reverse);
        };

        $scope.$on('instanceReady', function(event, data) {

            $scope.filteredItems = $scope.getFilteredItems();
        });

        $scope.$on('updateFilter', function(event, data) {

            $scope.filteredItems = $scope.getFilteredItems();
            $scope.order($scope.predicateAttribute, $scope.reverse);
        });

        $scope.range = function() {
            if (!$scope.instance) {
                return;
            }

            var rangeSize = ($scope.pageCount() >= $scope.MaxPages)? $scope.MaxPages : $scope.pageCount()+1;
            var ret = [];
            var start;

            start = $scope.currentPage;
            if ( start > $scope.pageCount()-rangeSize ) {
                start = $scope.pageCount()-rangeSize+1;
            }

            for (var i=start; i<start+rangeSize; i++) {
                ret.push(i);
            }
            return ret;
        };

        $scope.prevPage = function() {
            if ($scope.currentPage > 0) {
                $scope.currentPage--;
            }
        };

        $scope.prevPageDisabled = function() {
            return $scope.currentPage === 0 ? "disabled" : "";
        };

        $scope.getFilteredItems = function() {
            if (!$scope.instance) {
                return;
            }
            return $filter('filter')($scope.instance.LCPQuestionnaire.ListOfPlants.Plant, $scope.searchText);
        }

        $scope.refreshItems = function() {
            ////console.log("Filter changed. Getting new items...");
            $scope.filteredItems = $scope.getFilteredItems();
        };

        $scope.$watch('searchText', function(newValue, oldValue) {
            ////console.log("Filter changed. Getting new items...");
            $scope.filteredItems = $scope.getFilteredItems();
            if(newValue != oldValue){
                $scope.setPage(0);
            }
        });

        $scope.pageCount = function() {
            if (!$scope.instance || !$scope.filteredItems) {
                return;
            }

            var items = $scope.filteredItems;
            var count = Math.ceil(items.length/$scope.itemsPerPage)-1;
            return count;
        };

        $scope.nextPage = function() {
            if ($scope.currentPage < $scope.pageCount()) {
                $scope.currentPage++;
            }
        };

        $scope.nextPageDisabled = function() {
            return $scope.currentPage === $scope.pageCount() ? "disabled" : "";
        };

        $scope.setPage = function(n) {
            $scope.currentPage = n;
        };
        $scope.deleteSelected = function(selectedItems){
            var i;
            for (i = 0; i < selectedItems.length; ++i) {
                if(selectedItems[i].Delete != undefined){
                    if(selectedItems[i].Delete == true){
                        if ((countNonEmptyProperties(selectedItems[i]) > 0) && $scope.showMessage == false) {
                            if (!confirm('Are you sure you want to delete the selected rows?')){
                                $scope.showMessage = false;
                                return;
                                                                                        }
                            else{
                                $scope.showMessage = true;
                                }
                        }
                        $scope.remove($scope.instance.LCPQuestionnaire.ListOfPlants.Plant, selectedItems[i], false);
                    }
                }

            }

            $scope.showMessage = false;
            $rootScope.$broadcast('updateFilter');
        }
        $scope.edit = function (plant, modalPageId) {
            //$rootScope.$broadcast('editPlant', plant);
            $rootScope.selectedPlant = plant;
            $rootScope.modalPageCaseId = modalPageId;
/*
            var modalInstance = $modal.open({
                templateUrl: 'ListOfPlantModalContent.html',
                controller: 'ListOfPlantsModalInstanceCtrl',
                size: 'lg',
                scope: $scope,
                windowClass: 'app-modal-window',
                resolve: {
                    plant: function () {
                        return  plant;
                    }
                }
            });
            */
        };

        //orderObjectBy pagination
        //$scope.plantObjects = $scope.instance.LCPQuestionnaire.ListOfPlants.Plant;
        $scope.criteria = 'PlantName';
        $scope.direction = false;
        $scope.setCriteria = function(criteria) {
            if ($scope.criteria === criteria) {
                $scope.direction = !$scope.direction;
            } else {
                $scope.criteria = criteria;
                $scope.direction  = false;
            }
        }
    });


    // new end

    function getWebQUrl(path){
        var url = baseUri + path;
        url += "?fileId=" + fileId;
        if (sessionId && sessionId != null) {
            url += "&sessionid=" + sessionId;
        }
        return url;
    }
    // helper function for getting query string parameter values. AngularJS solution $location.search() doesn't work in IE8.
    function getParameterByName(name) {
        var searchArr = window.location.search.split('?');
        var search = '?' + searchArr[searchArr.length - 1];
        var match = new RegExp('[?&]' + name + '=([^&]*)').exec(search);
        return match && decodeURIComponent(match[1].replace(/\+/g, ' '));
    };

    function getHandsontableColHeaders(form) {
        if (form == 'ListOfPlants'){
            return ["Plant Name", "Plant Id", "E-PRTR national ID", "Street Name ", "City", "Region", "Postal code","Country Code","Building Number", "Longitude", "Latitude", "Facility name", "Comments"]
        }
        else if (form == 'PlantDetails'){
            return ["Plant name", "Plant ID", "MWth","Type of Combustion Plant", "Date of start of operation", "Refineries",  "Other Sector", "Operating Hours", "Derogation", "Comments"]
        }
        else if (form == 'EnergyInput'){
            return ["Plant name", "Plant ID", "Biomass (TJ)","Coal","Lignite","Peat", "Other solid fuels (TJ) Category","Other solid fuels (TJ) Value" , "Liquid fuels (TJ)", "Natural gas (TJ)", "Other gases (TJ) Category","Other gases (TJ) Value", "SO2 (t)", "NOx (t)", "Dust (t)"]
        }
        else if (form == 'TotalEmissionsToAir'){
            return ["Plant name", "Plant ID", "SO2 (t)", "NOx (t)", "TSP (t)"]
        }
        else if (form == 'Desulphurisation'){
            return ["Desulphurisation Rate", "Sulphur Content", "Technical Justification", "Month"]
        }
        else if (form == 'UsefulHeat'){
            return ["Plant name", "Plant ID","UsefulHeat Proportion"]
        }
        else {
            //default is the first table
            return ["Plant Name", "Plant Id", "E-PRTR national ID", "Address 1", "Address 2", "City", "Region", "Postal code", "Longitude", "Latitude", "Facility name"]
        }
    }
	app.directive('uiHandsontable', function () {
	return {
		restrict: 'A',
		scope: {
			data: '=',
            status: '=',
            formname: '='
		},
		replace: true,
		link: function (scope, elem, attrs) {
            scope.$watch('status', function(newValue, oldValue) {
                // console.log('watch:' + newValue + '; form=' + scope.formname);
                if(newValue == true && angular.isArray(scope.data)){
                    elem.handsontable('loadData', scope.data);
                }
            });
            //console.log(scope.formname);
            var data = scope.data;
            var formname = scope.formname;
            var container = elem;

            elem.handsontable({
			    data: data,
                    contextMenu:false,// ['row_above', 'row_below', 'remove_row'],
				rowHeaders: false,
                columnSorting: false,
                stretchH: 'all',
                fixedColumnsLeft: 2,
                minSpareRows: 0, // formname === 'ListOfPlants' ? 1 : 0,
            //    minRows:0,
                minSpareCols: 0,
                //maxRows: formname === 'ListOfPlants' ? 200 : data.length,
                //maxCols: data.numberOfColumns,
                colHeaders: getHandsontableColHeaders(formname),
      /**          modifyRow: function(row){
                    var ht = container.handsontable('getInstance');
                 //   var rowsNeeded = data.length - ht.countEmptyRows();
               //     console.log('rowIndex:'+row);
               if(row!=0){
                    var data = this.getData(row);
                    console.log("rowData"+data);
               }
                  //  for (var index = 0; index < rowsNeeded; index++) {
                  //  elem.handsontable('alter', 'insert_row');
                   // }
                 },
                 **/
                columns:
                        (formname === 'ListOfPlants' ?
                            [
                                {data: "PlantName"}, {data: "PlantId"},
                                {data: "EPRTRNationalId"},
                                {data: "PlantLocation.StreetName"},
                                  {data: "PlantLocation.City"}, {data: "PlantLocation.Region"}, {data: "PlantLocation.PostalCode"},{data: "PlantLocation.CountryCode"},{data: "PlantLocation.BuildingNumber"},
                                {data: "GeographicalCoordinate.Longitude", type: 'numeric', format: '0.[00000]'},
                                 {data: "GeographicalCoordinate.Latitude", type: 'numeric', format: '0.[00000]'},
                                {data: "FacilityName"},{data: "Comments"}
                            ]
                    : formname == 'PlantDetails' ?
                            [
                                {data: "PlantName", readOnly: true}, {data: "PlantId", readOnly: true},
                                {data: "PlantDetails.MWth"},
                                {data: "PlantDetails.TypeOfCombustionPlant"},
                                {data: "PlantDetails.DateOfStartOfOperation"},                                
                                {data: "PlantDetails.Refineries", type: 'checkbox'}, {data: "PlantDetails.OtherSector", type: 'dropdown', source: [{iron_steel:"iron_steel"}, "esi", "district_heating", "chp", "other"]},
                                {data: "PlantDetails.OperatingHours", type: 'numeric'},
                                {data: "PlantDetails.Derogation"},                                
                                {data: "PlantDetails.Comments"}
                            ]
                   : formname == 'EnergyInput' ?
                            [
                                {data: "PlantName", readOnly: true}, {data: "PlantId", readOnly: true},
                                {data: "EnergyInputAndTotalEmissionsToAir.EnergyInput.Biomass", type: 'numeric', format: '0.[00000]'},
                                {data: "EnergyInputAndTotalEmissionsToAir.EnergyInput.Coal", type: 'numeric', format: '0.[00000]'},
                                {data: "EnergyInputAndTotalEmissionsToAir.EnergyInput.Lignite", type: 'numeric', format: '0.[00000]'},
                                {data: "EnergyInputAndTotalEmissionsToAir.EnergyInput.Peat", type: 'numeric', format: '0.[00000]'},
                                {data: "EnergyInputAndTotalEmissionsToAir.EnergyInput.OtherSolidFuels.Category"},
                                {data: "EnergyInputAndTotalEmissionsToAir.EnergyInput.OtherSolidFuels.Value", type: 'numeric', format: '0.[00000]'},
                                {data: "EnergyInputAndTotalEmissionsToAir.EnergyInput.LiquidFuels", type: 'numeric', format: '0.[00000]'},
                                {data: "EnergyInputAndTotalEmissionsToAir.EnergyInput.NaturalGas", type: 'numeric', format: '0.[00000]'},
                                {data: "EnergyInputAndTotalEmissionsToAir.EnergyInput.OtherGases.Category"},
                                {data: "EnergyInputAndTotalEmissionsToAir.EnergyInput.OtherGases.Value", type: 'numeric', format: '0.[00000]'},

                            ]         
                    : formname == 'TotalEmissionsToAir' ?
                            [
                                {data: "PlantName", readOnly: true}, {data: "PlantId", readOnly: true},
                                {data: "EnergyInputAndTotalEmissionsToAir.TotalEmissionsToAir.SO2", type: 'numeric', format: '0.[00000]'},
                                {data: "EnergyInputAndTotalEmissionsToAir.TotalEmissionsToAir.NOx", type: 'numeric', format: '0.[00000]'},
                                {data: "EnergyInputAndTotalEmissionsToAir.TotalEmissionsToAir.TSP", type: 'numeric', format: '0.[00000]'}
                            ]
                    : formname == 'Desulphurisation' ?
                           [
                                {data: "PlantName", readOnly: true}, {data: "PlantId", readOnly: true},
                                {data: "Desulphurisation.DesulphurisationRate", type: 'numeric', format: '0.[00000]'},
                                {data: "Desulphurisation.SulphurContent", type: 'numeric', format: '0.[00000]'},
                                {data: "Desulphurisation.TechnicalJustification" }
                            ]
                    : formname == 'UsefulHeat' ?
                            [
                                {data: "PlantName", readOnly: true}, {data: "PlantId", readOnly: true},
                                {data: "UsefulHeat.UsefulHeatProportion", type: 'numeric', format: '0.[00000]'},
                            ]
                   
                    :[]),
                    onSelection: function (row, col, row2, col2) {
                        var meta = container.handsontable('getCellMeta', row2, col2);
                        if (meta.readOnly) {
                            container.handsontable('updateSettings', {fillHandle: false});
                        }
                        else {
                            container.handsontable('updateSettings', {fillHandle: true});
                        }
                    },
                cells: function (row, col, prop) {
                    var cellProperties = {};
                    if (conditionalReadonlyFields.indexOf(prop) >= 0) {
                        this.renderer = numericConditionalreadOnlyRenderer;
                    }
                    return cellProperties;
                }
        });
    }
	}
});
    var conditionalReadonlyFields = ["PlantDetails.CapacityAddedMW", "PlantDetails.CapacityAffectedMW", "PlantDetails.OtherSector", "PlantDetails.GasTurbineThermalInput",
        "PlantDetails.BoilerThermalInput", "PlantDetails.GasEngineThermalInput", "PlantDetails.DieselEngineTurbineThermalInput", "PlantDetails.DieselEngineTurbineThermalInput",
        "PlantDetails.OtherTypeOfCombustion", "PlantDetails.OtherThermalInput",
        "OptOutsAndNERP.CapacityOptedOutMW", "OptOutsAndNERP.HoursOperated",
        "LcpArt15.OperatingHours", "LcpArt15.ElvSO2",
        "LcpArt15.NotaBeneElvSO2", "LcpArt15.DesulphurisationRate", "LcpArt15.SInput",
        "LcpArt15.AnnexVI_A_Footnote2_OperatingHours", "LcpArt15.ElvNOx",
        "LcpArt15.VolatileContents", "LcpArt15.AnnexVI_A_Footnote3_ElvNOx"]
    function numericConditionalreadOnlyRenderer(instance, td, row, col, prop, value, cellProperties) {

        if (prop === "PlantDetails.OtherTypeOfCombustion") {
            Handsontable.renderers.TextRenderer.apply(this, arguments);
        }
        else if (prop === "PlantDetails.OtherSector") {
            Handsontable.renderers.AutocompleteRenderer.apply(this, arguments);
        }
        else {
            Handsontable.renderers.NumericRenderer.apply(this, arguments);
        }
        var colIndex = (
                (prop === "PlantDetails.OtherThermalInput" || prop ===  "OptOutsAndNERP.HoursOperated"
                                || prop === "LcpArt15.ElvSO2" || prop ===  "LcpArt15.DesulphurisationRate"
                                || prop === "LcpArt15.ElvNOx" || prop ===  "LcpArt15.AnnexVI_A_Footnote3_ElvNOx")
                                ? col - 2 : (prop === "LcpArt15.SInput") ? col - 3 : col - 1);
        var booleanValue = prop === "PlantDetails.OtherSector" ? false : true;
        var checkboxValue = instance.getDataAtCell(row, colIndex) === null || instance.getDataAtCell(row, colIndex) === '' ? false : instance.getDataAtCell(row, colIndex);
        if (checkboxValue != booleanValue ) {
            cellProperties.readOnly = true;
            td.style.background = '#EEE';
        }
    }
