\dontrun{

setReactiveS3(id = "x_1", value = 10)
setReactiveS3(id = "x_2", value = function() "object-ref: {id: x_1}")

showPushRefs(id = "x_1")
showPushRefs(id = "x_2")

setReactiveS3(id = "x_2", value = function() "object-ref: {id: x_1}", push = TRUE)
showPushRefs(id = "x_2")

## Clean up //
rmReactive("x_1")
rmReactive("x_2")

}