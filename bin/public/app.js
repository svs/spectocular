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
  $scope.loaded_files = {};
  $scope.line_highlights = {};
  Faye.subscribe('/example_finished', function(message) {
    console.log(message);
    $scope.$apply(function() {
      var a = $scope.tests;

      // go through the parents list and create a place in the tree
      // for each example group, children, etc.
      _.each(message.parents, function(n, i) {
	console.log(n,i);
	if (_.isUndefined(a)) { a = {_children: [], _stats: {}, _tests: []}; };
	if (i == message.parents.length - 1) {
	  a['_tests'].push(message.execution_result);
	}
	a = a['_children'];
      });
      console.log($scope.tests);


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
    $scope.$apply(function() {
      console.log(message);
      if (!_.isEmpty(message.parents)) {
	var st = "$scope.tests['" + message.parents.join("']['") + "'] = []";
	console.log(st);
      }
    });
  });

  Faye.subscribe('/lm-ctrl', function(message) {
    $scope.$apply(function() {
      console.log(message);
    });
  });


});
