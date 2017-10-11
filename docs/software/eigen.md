# [Eigen](https://eigen.tuxfamily.org/dox/index.html)




## Vectors
```
VectorXd v(3);
v << 1,2,3; // assign values by streams;

// Assign values 
v[0] = 1.0;
// Access values
double temp = v[1];
```


##Matrix

```
// #include <Eigen/Dense>
Eigen::MatrixXd m(2,2); // define a 2 by 2 matrix with elements type double.
//Assign elements to matrix m
m(i,j) = 2.5;
// Access the elements of m
double temp = m(i,j)

// Initialize with random
MatrixXd m = MatrixXd::Random(3,3); // is Random suppourted for all Matrix type or just Xd ?
```



## Get in and out data from Eigen matrix with Eigen::Map

### Copy in
Suppose you have an array with dounle values of size nRows * nCols
```c++
 double *X; // non-NULL pointer to some data
 MatrixXd eigenX = Map<MatrixXd>( X, nRows, nCols);

```

The map operation maps the existing memory region into the Eigen's data structres. 
A single line like this allows to avoid to write ugly code of matrix creation, 
for loop with copying each element in good order etc.

### Copy out
If we have got an Eigen matrix with some resilt and you want to get out a plain double array:

```c++
MatrixXd resultEigen; // Eigen matrix with some result(non NULL)
double * resultC; //NULL pointer, do not need to allocate memery first ??
Map<MatrixXd>( resultC, resultEigen.rows(), resultEigen.cols()) = resultEigen;
``` 

# [Eigen-unsupported](https://eigen.tuxfamily.org/dox/unsupported/index.html)