##------------------------------------------------------------------------------
context("copyReactive/ReactiveObject.S3")
##------------------------------------------------------------------------------

test_that("copyReactive/ReactiveObject.S3", {

  setReactive(id = "x_1", value = 10)
  expect_equal(copyReactive(id_from = "x_1", id_to = "x_1_c"), 10)
  expect_equal(x_1_c, 10)
  x_1 <- 20
  expect_equal(x_1_c, 10)
  x_1_reg <- getFromRegistry("x_1")
  expect_is(x_1_reg, "ReactiveObject.S3")
  x_1_c_reg <- getFromRegistry("x_1_c")
  expect_false(identical(x_1_reg, x_1_c_reg))
  
})

##------------------------------------------------------------------------------
context("copyReactive/ReactiveShinyObject")
##------------------------------------------------------------------------------

test_that("copyReactive/ReactiveShinyObject", {

  skip("legacy")
  setShinyReactive(id = "x_1", value = 10)
  expect_equal(copyReactive(id_from = "x_1", id_to = "x_1_c"), 10)
  expect_equal(x_1_c, 10)
  x_1 <- 20
  expect_equal(x_1_c, 10)
  x_1_reg <- getFromRegistry("x_1")
  expect_is(x_1_reg, "ReactiveShinyObject")
  x_1_c_reg <- getFromRegistry("x_1_c")
  expect_false(identical(x_1_reg, x_1_c_reg))
  
})
