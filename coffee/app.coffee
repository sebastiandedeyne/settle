# Application setup
###########################################################

window.Settle = angular.module 'Settle', []
do Settle.run


# Controller
###########################################################

Settle.controller 'IndexController', [
  '$scope', 'PersonModel', 'ItemModel', 'DataService', 'SettleService',
  ($scope, Person, Item, DataService, SettleService) ->

    # The data
    $scope.persons = DataService.persons
    $scope.items = DataService.items

    # Passive calculations
    $scope.personHasItem = SettleService.personHasItem
    $scope.getPersonsTotal = SettleService.getPersonsTotal

    # Add and edit data
    $scope.toggleItem = SettleService.toggleItem
    $scope.addPerson = SettleService.addPerson
    $scope.addItem = SettleService.addItem

    # On init
    do SettleService.addPerson
    do SettleService.addItem
      
    return
]


# Services
###########################################################

Settle.service 'SettleService', [
  'PersonModel', 'ItemModel', 'DataService', (Person, Item, DataService) ->

    @personHasItem = (personId, itemId) =>
      _.find DataService.items, (item) ->
        item.id is itemId and _.contains item.persons, personId 
    
    @getPersonsItems = (personId) =>
      _.filter DataService.items, (item) ->
        _.contains item.persons, personId

    @getPersonsTotal = (personId, pretty) =>
      sum = 0
      items = @getPersonsItems personId

      angular.forEach items, (item) =>
        price = do item.singlePrice
        if _.isNumber price
          sum += price

      if pretty
        sum.toFixed(2)
      else
        sum

    @toggleItem = (personId, itemId) =>
      item = _.find DataService.items, { id: itemId }
      if _.indexOf(item.persons, personId) isnt -1
        item.persons = _.without item.persons, personId
      else
        item.persons.push personId
      return

    @addPerson = DataService.addPerson
    @addItem = DataService.addItem

    return
]

Settle.service 'DataService', [
  'PersonModel', 'ItemModel', (Person, Item) ->
    
    @persons = []
    personCounter = 1

    @addPerson = (name) =>
      person = new Person(name)
      person.id = personCounter
      personCounter++
      @persons.push person

    # Items
    @items = []
    itemCounter = 1

    @addItem = (name, price) =>
      item = new Item(name, price)
      item.id = itemCounter
      itemCounter++
      @items.push item


    # FIXTURES 

    RAW = {
      persons: [
        { id: 1, name: 'Sebastian' },
        { id: 2, name: 'Stijn' },
        { id: 3, name: 'Gennadi' }
      ],
      items: [
        { id: 1, name: 'Gin', price: 13.00, persons: [1, 2] },
        { id: 2, name: 'Tonic', price: 2.00, persons: [1, 2] },
        { id: 3, name: 'Vlees', price: 4.00, persons: [1, 2, 3] },
        { id: 4, name: 'Tomaat', price: 1.00, persons: [1, 2, 3] },
        { id: 5, name: 'Cola', price: 2.00, persons: [3] }
      ]
    }

    angular.forEach RAW.persons, (personData) =>
      person = new Person()
      person.id = personData.id
      person.name = personData.name
      personCounter = personData.id + 1
      @persons.push person

    angular.forEach RAW.items, (itemData) =>
      item = new Item()
      item.id = itemData.id
      item.name = itemData.name
      item.price = itemData.price
      item.persons = itemData.persons
      itemCounter = itemData.id + 1
      @items.push item

    return
]


# Models
###########################################################

Settle.factory 'PersonModel', [
  () ->
    Person = (name) ->
      @id = null
      @name = name || ''
      return
    return Person
]

Settle.factory 'ItemModel', [
  ()->
    Item = (name, price) ->

      @id = null
      @name = name || ''
      @persons = []
      @price = price || 0

      @hasPerson = (personId) =>
        _.contains @persons, personId

      @singlePrice = (pretty) =>
        price = @price / @persons.length
        if pretty
          price.toFixed(2)
        else
          price

      return
    return Item
]
