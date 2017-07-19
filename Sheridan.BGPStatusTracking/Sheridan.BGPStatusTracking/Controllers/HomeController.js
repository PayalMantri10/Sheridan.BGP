  app.controller("HomeController", function($scope,$http){

      $scope.IsVisible = false;
    
      $scope.ButtonOnClick = function () {
          $http.get('/Home/GetBGP')
              .then(function (response) {
                  alert(response);
                  $scope.response = response;
                  console.log(response);
              })
              .error(function (response) {
                  alert("error");
              });
      }

      $scope.ShowHide = function (BGPRunStatus) {
          console.log(BGPRunStatus);
          console.log(BGPRunStatus.BGPName)
          //If DIV is visible it will be hidden and vice versa.
          $scope.IsVisible = $scope.IsVisible ? false : true;
      }

  /*	$scope.ContactPage=function(){
  		$location.path('/contact')
  	}*/
  })