Snap = require "snapsvg"
humane = require "humane-js"
_ = require "underscore"

paper = Snap "#graph"

light = "#aedfdf"
dark = "#296f6d"

dfs_waitChoosingNode = no
bfs_waitChoosingNode = no

nodeStyle =
  fill: light
  stroke: dark
  strokeWidth: 3
  transform: "s1,1" # reset prevNodeStyle

prevNodeStyle =
  transform: "s1.2,1.2"

pathStyle =
  fill: "transparent"
  stroke: "#71c3cf"
  strokeWidth: 3

path = paper
  .path ""
  .attr pathStyle

mousedownCoords = undefined
adjacencyMatrix = []

pathArray = []
nodes = []

existLink = (node1, node2, callback) ->
  for pair in pathArray
    if pair.from is node1 and pair.to is node2 or pair.from is node2 and pair.to is node1
      callback(pair) if typeof callback is "function"
      return yes
  no


#< Переменные для updateTable
side = 30
start = 25
gap = 5
active =
  fill: light
  stroke: "#003d50"
  strokeWidth: 1
inactive =
  fill: "#003d50"
  stroke: light
  strokeWidth: 1
tableArray = []
#/>

updateTable = ->
  for e in tableArray
    do e.remove

  for i in [0..nodes.length]
    ynumber = paper
      .text 10, i * (side + gap) + 8, i
    xnumber = paper
      .text i * (side + gap), start - gap, i
    tableArray.push ynumber, xnumber

  for x in [0...nodes.length]
    for y in [0...nodes.length]

      exist = existLink nodes[x], nodes[y]
      adjacencyMatrix[x] ||= []
      adjacencyMatrix[x][y] = exist

      indicator = paper
        .rect start + x * (side + gap), start + y  *(side + gap), side, side, 5
        .attr if exist then active else inactive
        .data "x", x
        .data "y", y

        .click ->
          from = nodes[@data "x"]
          to = nodes[@data "y"]

          #< удалить путь, если он eсть и добавить, если его нет
          if existLink from, to
            pathArray = pathArray.filter (e) -> (not _.isEqual e, {from: from, to: to}) and (not _.isEqual e, {from: to, to: from})
          else
            pathArray.push
              from: from
              to: to
          #/>

          do updatePath
          do updateTable

      tableArray.push indicator

updatePath = ->
  pathString = ""

  for pathPart in pathArray

    from =
      x: pathPart.from.node.cx.baseVal.value
      y: pathPart.from.node.cy.baseVal.value
    to =
      x: pathPart.to.node.cx.baseVal.value
      y: pathPart.to.node.cy.baseVal.value

    if _.isEqual from, to
      pathString += "M#{to.x},#{to.y}A 20,20 0 1,0 #{to.x-1},#{to.y-1}"
    else
      pathString += "M#{from.x},#{from.y}L#{to.x},#{to.y}"

  path.attr d: pathString

ex = []
timeDfs = 1
timers = []

dfs = (start, withAnimation) ->
  if withAnimation is undefined
    withAnimation = yes
  ex.push start
  for i in [0...adjacencyMatrix.length]
    if ex.indexOf(i) is -1 and adjacencyMatrix[start][i]
      if withAnimation
        timer = setTimeout (->
          @animate fill: "#f96ba2", 300, mina.linear, ->
            setTimeout (-> @animate fill: light, 300, mina.linear).bind(this), 500
        ).bind(nodes[i]), 500 * timeDfs++
        timers.push timer
      dfs i, withAnimation
  ex

resetGraphAnimation = ->
  for node in nodes
    node.attr fill: light
  timeDfs = 1
  ex = []
  for timer in timers
    clearTimeout timer

messageIsShown = no

startDfs = (start) ->
  do resetGraphAnimation
  if nodes[start]
    nodes[start].animate fill: "#93f8a5", 300, mina.linear, ->
      setTimeout (-> @animate fill: light, 300, mina.linear).bind(this), 500
  dfs start

#< drawing dfs button
dfsButtonStroke = paper
  .rect 0, 0, 190, 40, 5
  .attr
    fill: "none"
    stroke: light
    strokeWidth: 2

dfsButtonRect = paper
  .rect 0, 0, 190, 40, 5
  .attr
    fill: light
    opacity: 0
    strokeWidth: 2

dfsButtonText = paper
  .text 24, 25, "Depth First Search"
  .attr
    fill: light
    fontSize: 18
    fontWeight: 200

paper.group dfsButtonRect, dfsButtonStroke, dfsButtonText
  .attr
    transform: "t#{screen.width - 200},10"
  .hover ->
      dfsButtonRect.animate opacity: 1, 200, mina.linear
      dfsButtonText.animate fill: dark, 200, mina.linear
    ,->
      dfsButtonRect.animate opacity: 0, 200, mina.linear
      dfsButtonText.animate fill: light, 200, mina.linear
  .click ->
    unless messageIsShown
      messageIsShown = yes
      humane.log "Chose node for start", -> messageIsShown = no
    dfs_waitChoosingNode = yes
#/>

#< drawing find comps button
findCompsButtonStroke = paper
  .rect 0, 0, 190, 40, 5
  .attr
    fill: "none"
    stroke: light
    strokeWidth: 2

findCompsButtonRect = paper
  .rect 0, 0, 190, 40, 5
  .attr
    fill: light
    opacity: 0
    strokeWidth: 2

findCompsButtonText = paper
  .text 24, 25, "Find Components"
  .attr
    fill: light
    fontSize: 18
    fontWeight: 200

paper.group findCompsButtonRect, findCompsButtonStroke, findCompsButtonText
  .attr
    transform: "t#{screen.width - 200},60"
  .hover ->
      findCompsButtonRect.animate opacity: 1, 200, mina.linear
      findCompsButtonText.animate fill: dark, 200, mina.linear
    ,->
      findCompsButtonRect.animate opacity: 0, 200, mina.linear
      findCompsButtonText.animate fill: light, 200, mina.linear
  .click ->
    unless messageIsShown
      messageIsShown = yes
      humane.log "Finding connected components", -> messageIsShown = no
      do findComps
#/>

#< drawing bfs button
_y = 50
bfsButtonStroke = paper
  .rect 0, 0 + _y, 190, 40, 5
  .attr
    fill: "none"
    stroke: light
    strokeWidth: 2

bfsButtonRect = paper
  .rect 0, 0 + _y, 190, 40, 5
  .attr
    fill: light
    opacity: 0
    strokeWidth: 2

bfsButtonText = paper
  .text 15, 25 + _y, "Breadth First Search"
  .attr
    fill: light
    fontSize: 18
    fontWeight: 200

paper.group bfsButtonRect, bfsButtonStroke, bfsButtonText
  .attr
    transform: "t#{screen.width - 200},60"
  .hover ->
      bfsButtonRect.animate opacity: 1, 200, mina.linear
      bfsButtonText.animate fill: dark, 200, mina.linear
    ,->
      bfsButtonRect.animate opacity: 0, 200, mina.linear
      bfsButtonText.animate fill: light, 200, mina.linear
  .click ->
    unless messageIsShown
      messageIsShown = yes
      humane.log "Chose node for start", -> messageIsShown = no
    bfs_waitChoosingNode = yes

bfs = (unit, adj) ->
  timeBfs = 1
  result = []
  queue = []
  visited = []
  for i in [0...adj.length]
    queue[i] = 0

  head = 0
  count = 0

  queue[count++] = unit
  visited[unit] = yes
  while head < count
    unit = queue[head++]
    result.push unit + 1

    for i in [0...adj.length]
      if adj[unit][i] and not visited[i]
        queue[count++] = i
        visited[i] = yes

  for i in result[1..-1]
    timer = setTimeout (->
      @animate fill: "#f96ba2", 300, mina.linear, ->
        setTimeout (-> @animate fill: light, 300, mina.linear).bind(this), 500
    ).bind(nodes[i-1]), 500 * timeBfs++
    timers.push timer


startBfs = (start) ->
  do resetGraphAnimation
  if nodes[start]
    nodes[start].animate fill: '#93f8a5', 300, mina.linear, ->
      setTimeout (-> @animate fill: light, 300, mina.linear).bind(this), 500
  bfs start, adjacencyMatrix

#/>

findComps = ->
  timeOffset = 0
  visited = []
  do resetGraphAnimation
  for i in [0...nodes.length]
    if visited.indexOf i is -1
      comp = dfs i, false
      visited.concat comp
      timeOffset++
      comp.forEach (e) -> setTimeout (->
          @animate fill: "red", 500, mina.linear, ->
            @animate fill: light, 500, mina.linear
        ).bind(nodes[e]), 500 * timeOffset


prevNode = undefined

paper.click (e) ->
  if e.target.tagName is "svg"
    node = paper
      .circle e.offsetX, e.offsetY, 20
      .data "i", nodes.length
      .attr nodeStyle
      .attr transform: "s0,0"
      .animate transform: "s1,1", 1000, mina.elastic

    t = paper.text e.offsetX - 4, e.offsetY + 5, nodes.length + 1

    node
      .data "t", t
      .drag (dx, dy, x, y) ->
        t = @data "t"
        t.attr
          x: x - 4
          y: y + 5
        @attr
          cx: x
          cy: y
        do updatePath

      .mousedown (e) ->
        mousedownCoords =
          x: e.offsetX
          y: e.offsetY

      .mouseup (e) ->
        if dfs_waitChoosingNode
          startDfs @data "i"
          dfs_waitChoosingNode = no
          return
        else if bfs_waitChoosingNode
          startBfs @data "i"
          bfs_waitChoosingNode = no
          return

        mouseupCoords =
          x: e.offsetX
          y: e.offsetY

        if _.isEqual(mousedownCoords, mouseupCoords) or (this is prevNode)
          if prevNode
            from =
              x: prevNode.node.cx.baseVal.value
              y: prevNode.node.cy.baseVal.value
            to =
              x: @node.cx.baseVal.value
              y: @node.cy.baseVal.value

            pathArray.push
              from: prevNode
              to: this

            do updatePath
            do updateTable

            prevNode.stop().animate nodeStyle, 1000, mina.elastic
            prevNode = undefined

          else # if prevNode is undefined
            @animate prevNodeStyle, 1000, mina.elastic
            prevNode = this

    nodes.push node
    do updateTable
