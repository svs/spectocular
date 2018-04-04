angular.module('Fdt', [])
  .directive('prism', [  '$timeout',
  function($timeout) {
    return {
      restrict: 'AC',
      priority: 0,
      compile: function(tElement, tAttributes, transclude) {
        return {
          pre: function(scope, element, attributes) {},
          post: function(scope, element, attributes) {
            var $element = element;
	    $element.addClass('language-ruby');
            $timeout(function(){Prism.highlightElement($element.find('code')[0])}, 3000);
          }
        };
      }
    };
  }
]);

var liveMetricsApp = angular.module('liveMetricsApp', ['Fdt']);

liveMetricsApp.factory('Faye', function() {
  var client = new Faye.Client('http://localhost:9292/faye');

  return {
    publish: function(channel, message) {
      client.publish(channel, message);
    },

    subscribe: function(channel, callback) {
      client.subscribe(channel, callback);
    }
  };
});



liveMetricsApp.controller('MetricsCtrl', function($scope, $http, Faye) {
    $scope.tests = {_children: [], _stats:{}, _tests: [] };
    $scope.runs = {};
  $scope.loaded_files = {};
  $scope.line_highlights = {};
  Faye.subscribe('/example_finished', function(message) {
    console.log(message);
      $scope.$apply(function() {
	  var o = {};
	  o[message.description] = message.status;
	  _.set($scope.runs, message.parents.join("."), o);
      var a = $scope.tests;
      angular.forEach(message.trace, function(t) {
	if (_.isEmpty($scope.line_highlights[t.path])) {
	  $scope.line_highlights[t.path] = [];
	}
	$scope.line_highlights[t.path].push(t.line);
      });
      message.files.push(message.file_path);
      angular.forEach(message.files, function(f) {
	$http.get('/files?name=' + f).success(function(r) {
	  $scope.loaded_files[f] = r;
	});
      });
    });
  });




    Faye.subscribe('/example_group_started', function(message) {
	console.log(["example group started", message]);
	$scope.$apply(function() {
	    console.log("runs",$scope.runs);
	    var p = [];
	    if (!_.isEmpty(message.parents)) {
		p.push(message.parents);
	    }
	    p.push(message.name);
	    _.set($scope.runs, p.join("."), {});
	    console.log("runs",$scope.runs);
	});
    });

  Faye.subscribe('/lm-ctrl', function(message) {
    $scope.$apply(function() {
      console.log(message);
    });
  });


});
