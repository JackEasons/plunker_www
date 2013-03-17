#= require ./../services/menu
#= require ./../services/plunks
#= require ./../services/url

#= require ./../directives/gallery
#= require ./../directives/overlay
#= require ./../directives/pager

module = angular.module "plunker.explore", [
  "plunker.gallery"
  "plunker.pager"
  "plunker.overlay"
  "plunker.menu"
  "plunker.plunks"
  "plunker.url"
]

filters =
  trending:
    href: "/plunks/trending"
    text: "Trending"
    order: "c"
  popular:
    href: "/plunks/popular"
    text: "Popular"
    order: "b"
  recent:
    href: "/plunks/recent"
    text: "Recent"
    order: "a"

resolvers =
  trending: ["$location", "url", "plunks", ($location, url, plunks) ->
    plunks.query(url: "#{url.api}/plunks/trending", params: $location.search()).$$refreshing
  ]
  popular: ["$location", "url", "plunks", ($location, url, plunks) ->
    plunks.query(url: "#{url.api}/plunks/popular", params: $location.search()).$$refreshing
  ]
  recent: ["$location", "url", "plunks", ($location, url, plunks) ->
    plunks.query(url: "#{url.api}/plunks", params: $location.search()).$$refreshing
  ]

generateRouteHandler = (filter, options = {}) ->
  angular.extend
    templateUrl: "partials/explore.html"
    resolve:
      filtered: resolvers[filter]
    reloadOnSearch: true
    controller: ["$rootScope", "$scope", "menu", "filtered", ($rootScope, $scope, menu, filtered) ->
      $rootScope.page_title = "Explore"
      
      $scope.plunks = filtered
      $scope.filters = filters
      $scope.activeFilter = filters[filter]
      
      menu.activate "plunks" unless options.skipActivate
    ]
  , options

module.config ["$routeProvider", ($routeProvider) ->
  $routeProvider.when "/", generateRouteHandler("trending", {templateUrl: "partials/landing.html", skipActivate: true})
  $routeProvider.when "/plunks", generateRouteHandler("trending")
  $routeProvider.when "/plunks/#{view}", generateRouteHandler(view) for view in ["trending", "popular", "recent"]
]

module.run ["menu", (menu) ->
  menu.addItem "plunks",
    title: "Explore plunks"
    href: "/plunks"
    'class': "icon-th"
    text: "Plunks"
]

module.run ["$templateCache", ($templateCache) ->
  $templateCache.put "partials/explore.html", """
    <div class="container">
      <plunker-pager class="pull-right" collection="plunks"></plunker-pager>
      
      <ul class="nav nav-pills pull-left">
        <li ng-repeat="(name, filter) in filters | orderBy:'text':true" ng-class="{active: filter == activeFilter}">
          <a ng-href="{{filter.href}}" ng-bind="filter.text"></a>
        </li>
      </ul>
    
      <div class="row">
        <div class="span12">
          <plunker-gallery plunks="plunks"></plunker-gallery>
        </div>
      </div>
    
      <plunker-pager class="pagination-right" collection="plunks"></plunker-pager>
    </div>
  """
  
  $templateCache.put "partials/landing.html", """
    <div class="container plunker-landing">
      <div class="hero-unit">
        <h1>
          Plunker
          <small>Helping developers make the web</small>  
        </h1>
        <p class="description">
          Plunker is an online community for creating, collaborating on and sharing your web development ideas.
        </p>
        <p class="actions">
          <a href="/edit/" class="btn btn-primary">
            <i class="icon-edit"></i>
            Launch the Editor
          </a>
          <a href="/plunks" class="btn btn-success">
            <i class="icon-th"></i>
            Browse Plunks
          </a>
        </p>
      </div>
      
      <div class="row">
        <div class="span4">
          <h4>Design goals</h4>
          <ul>
            <li><strong>Speed</strong>: Despite its complexity, the Plunker editor is designed to load in under 2 seconds.</li>
            <li><strong>Ease of use</strong>: Plunker's features should just work and not require additional explanation.</li>
            <li><strong>Collaboration</strong>: From real-time collaboration to forking and commenting, Plunker seeks to encourage users to work together on their code.</li>
          </ul>
        </div>
        <div class="span4">
          <h4>Features</h4>
          <ul>
            <li>Real-time code collaboration</li>
            <li>Fully-featured, customizable syntax editor</li>
            <li>Live previewing of code changes</li>
            <li>As-you-type code linting</li>
            <li>Forking, commenting and sharing of Plunks</li>
            <li>Fully open-source on Github under the MIT license</li>
            <li>And many more to come...</li>
          </ul>
        </div>
        <div class="span4">
          <h4>Thanks</h4>
          <p><a href="http://nodejitsu.com" title="NodeJitsu"><img src="/img/Nodejitsu.png" /></a>
          is the what has allowed Plunker to be on the Internet. If you use Node.js and want
          zero-downtime, command-line deploys, check them out.
          </p>
          <p><a href="http://mongolab.com" title="MongoLab"><img src="/img/Mongolab.png" /></a>
          has generously provided the back-end storage for Plunker. If you are looking for
          good service and easy set-up, check them out.
          </p>
        </div>
    
      </div>
      
      <div class="page-header">
        <h1>See what users have been creating</h1>
      </div>
      
      <plunker-pager class="pull-right" path="/plunks/" collection="plunks"></plunker-pager>
      
      <ul class="nav nav-pills pull-left">
        <li ng-repeat="(name, filter) in filters | orderBy:'text':true" ng-class="{active: filter == activeFilter}">
          <a ng-href="{{filter.href}}" ng-bind="filter.text"></a>
        </li>
      </ul>
    
      <div class="row">
        <div class="span12">
          <plunker-gallery plunks="plunks"></plunker-gallery>
        </div>
      </div>
    
      <plunker-pager class="pagination-right" path="/plunks/" collection="plunks"></plunker-pager>
    </div>
  """
]
