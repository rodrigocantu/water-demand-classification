## Water Demand Classification: Indoors vs. Outdoors

<img src="https://github.com/rodrigocantu/water-demand-classification/blob/main/resources/img/UC-Davis-Logo.png"  width="280" height="84"> &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; <img src="https://github.com/rodrigocantu/water-demand-classification/blob/main/resources/img/tecnologico-de-monterrey-logo.png"  width="315" height="84"> 

## Problem definition
Distinct data for residential outdoor and indoor water usage is needed to expressly **differentiate** the water used for irrigation. This can be done by surveying a sample of houses for a sample of cities; however, this is *costly and impractical*.

## Objective
To develop a water usage **disaggregation algorithm** that, given the total hourly water consumption of a house, differentiates the outdoors and indoors consumption.

## The Dataset
The data used for this project is the [*Residential End Uses of Water 2016 (REU16)*](https://www.circleofblue.org/wp-content/uploads/2016/04/WRF_REU2016.pdf) datasets collected by The Water Research Foundation. The first dataset contains discrete daily outdoors and indoors water usage, which is broken down into individual uses, such as bathtub, faucet, irrigation, etc. The second one contains total hourly data, which is not differentiable between the outdoors and indoors demands.

Both datasets are composed of the same 762 single-family homes expressed as keycodes. Each keycode has several sample dates. However, **these dates are not continuous, nor are they the same dates from keycode to keycode. This means that making a temporal or seasonal analysis is not possible**.

Each keycode is part of 1 of 9 water agencies spread across the U.S, shown in Table 1. However, **about 78% of the keycodes do not have an outdoor water usage**. Because of this, **the 165 keycodes that do have outdoor demand were isolated as the main database**. This leaves only 4 water agencies out of the original 9.

### Table 1. Original REU2016 Database
| Water Department                   | Number of households |
|------------------------------------|----------------------|
| Denver                             | 97                   |
| Fort Collins                       | 88                   |
| Scottsdale                         | 96                   |
| San Antonio                        | 90                   |
| Clayton                            | 96                   |
| Toho                               | 66                   |
| Peel                               | 60                   |
| Waterloo                           | 71                   |
| Tacoma                             | 98                   |
| Total                              | 762                  |

With this information, both hourly and daily databases were filtered so that only the aforementioned 165 keycodes remained. Each keycode was then labeled by its water agency: Denver, Fort Collins, Scottsdale, and San Antonio. These are called *the Total Datasets* because they **contain both indoor and outdoor data**.

The other 567 keycodes were filtered so that only the ones from Denver, Fort Collins, Scottsdale, and San Antonio remained. These are called *the Indoor Datasets*, because they contain only indoor data and is comprised by 206 keycodes as shown in **Table 2**. The proportion of outdoors+indoors versus indoors only is shown in **Figure 1** and **Figure 2**.

### Table 2. Used water agencies and number households
| Water Department | Outdoors + Indoors | Indoors Only | Total households |
|------------------|--------------------|--------------|------------------|
| Denver           | 10                 | 87           | 97               |
| Fort Collins     | 63                 | 25           | 88               |
| Scottsdale       | 23                 | 73           | 96               |
| San Antonio      | 69                 | 21           | 90               |
| Totals           | 165                | 206          | 371              |

![Figure 1. Number of water agencies and households](https://github.com/rodrigocantu/water-demand-classification/blob/main/resources/img/figure-1.JPG?raw=true)

![Figure 2. Proportion of indoors vs. outdoors water demand](https://github.com/rodrigocantu/water-demand-classification/blob/main/resources/img/figure-2.JPG?raw=true)

Disclaimer: Because the REU16 database is a paid resource, it cannot be shared here. However, more information about the database is provided [here.](https://github.com/rodrigocantu/water-demand-classification/blob/main/resources/REU2016%20Database%20Summary.pdf)

## Methodology
Overall, it is considered that the best course of action for this specific case is to perform a **classification model**. However, because of the aforementioned limitations of the dataset, the methodology will be divided into **3 sections**:
## 1. [Pattern extraction:](https://github.com/rodrigocantu/water-demand-classification/tree/main/pattern%20extraction)
  This method was derived from the MATLAB's section of the [Monthly Pattern Extraction of Hourly Values](https://github.com/rodrigocantu/data-manipulation-scripts/tree/main/Pattern%20Extraction) script.
  It pretends to find a daily water usage pattern for every water agency region for the two hourly datasets: The Total Dataset, and the Indoor Dataset. The **goal** is to have a pattern that represents the water use with both indoor and outdoor demand, and one that represents the water use with only the indoor component. **The differences between the two patterns will be defined as the irrigation window**. This is a period of the day in which people water their yard.
  This is achieved by using polynomial regression function. Explicitly, the fit model used was MATLAB’s Curve Fitting Toolbox *sin8* function which is based on the following expression:

  ![Sum of sines](https://github.com/rodrigocantu/water-demand-classification/blob/main/resources/img/equation-1.JPG?raw=true)

***
### Pseudocode:
```
  normalize all data
  for the Total and the Indoor Datasets:
      for all the water agencies:
          for all the keycodes in those water agencies:
              y = vector column of the hourly demands
              x = list from 1 to 24
              get a polynomial regression function(x, y)
              mat = save a matrix with all the keycode’s polynomial regression function evaluated hourly
              total_mean = vector column with the average of mat using Total Database
              indoor_mean = vector column with the average of mat using Indoor Database
              total = get a polynomial regression function(x, total_mean)
              indoors = get a polynomial regression function(x, indoor_mean)
              num_total = (total fit function evaluated in x)*(global total demand)
              num_indoors = (indoors fit function evaluated in x)*(global indoors demand)
              num_outdoors = (num_total – num_indoors)/ (global outdoors demand)
              outdoors = get a polynomial regression function(x, num_outdoors)
          end
      end
  >end  
```
***

  The tables 3 and 4 contain the coefficients generated with this method, and figure 2 contains the extracted patterns.

### Table 3. Coefficients for the **Indoors Database** sin8 formula
| Coefficients | Denver       | Fort Collins | Scottsdale   | San Antonio  |
|--------------|--------------|--------------|--------------|--------------|
| a1           | 0.065460935  | 0.067139712  | 0.067180644  | 0.068841587  |
| b1           | 0.135430876  | 0.136447142  | 0.136501433  | 0.140395004  |
| c1           | -0.120567626 | -0.197066163 | -0.209458607 | -0.282105734 |
| a2           | 0.01431812   | 0.02045894   | 0.020522328  | 0.01956909   |
| b2           | 0.283972506  | 0.553704919  | 0.273119698  | 0.273123236  |
| c2           | 1.337854409  | 2.621303076  | 1.446356845  | 1.245983103  |
| a3           | 0.014595552  | 0.014654439  | 0.011421479  | 0.014904505  |
| b3           | 0.534534781  | 0.273000451  | 0.553693887  | 0.548047728  |
| c3           | 3.054298027  | 1.093429675  | 3.021382086  | 2.32383938   |
| a4           | 0.008415201  | 0.009669058  | 0.008101396  | 0.00690378   |
| b4           | 0.808166448  | 0.818866114  | 0.819308248  | 0.808311539  |
| c4           | 1.46327883   | 1.408522618  | 1.506872338  | 1.072815226  |
| a5           | 0.003909752  | 0.003417743  | 0.003873602  | 0.002774221  |
| b5           | 1.104266769  | 1.364230398  | 1.631940301  | 1.093059244  |
| c5           | -0.131335986 | 2.855942489  | 1.848594294  | -0.445245321 |
| a6           | 0.002308641  | 0.004906402  | 0.005207504  | 0.000852019  |
| b6           | 1.381123175  | 1.092720058  | 1.357609719  | 1.914876152  |
| c6           | -2.709499337 | -0.837251399 | -1.432160191 | -2.913321376 |
| a7           | 0.001646258  | 0.002184518  | 0.005018309  | 0.00231457   |
| b7           | 1.621437411  | 1.638240429  | 1.092323032  | 1.640428954  |
| c7           | 1.916117072  | 0.646817779  | 0.531216069  | 1.113395389  |
| a8           | 0.000520307  | 0.000961223  | 0.002043035  | 0.001598901  |
| b8           | 2.425997712  | 2.458569188  | 1.913874883  | 1.437584629  |
| c8           | -0.464712795 | 0.210971618  | 2.689261879  | 1.587216705  |

### Table 4. Coefficients for the **Total Database** sin8 formula
| Coefficients | Denver       | Fort Collins | Scottsdale   | San Antonio  |
|--------------|--------------|--------------|--------------|--------------|
| a1           | 0.068948353  | 0.067664872  | 0.067253547  | 0.067153666  |
| b1           | 0.136087905  | 0.136459734  | 0.136775954  | 0.136103825  |
| c1           | -0.09749585  | -0.062057651 | 0.134615189  | -0.243424185 |
| a2           | 0.039263374  | 0.030399589  | 0.035720726  | 0.023622547  |
| b2           | 0.546339292  | 0.273547483  | 0.281150771  | 0.274507453  |
| c2           | -2.594379155 | 2.470586935  | 0.935056373  | 1.662230278  |
| a3           | 0.032733907  | 0.011412447  | 0.022714559  | 0.017950774  |
| b3           | 1.092856633  | 0.546363531  | 0.554544868  | 0.54624161   |
| c3           | -0.053645357 | -2.807940185 | -2.956835627 | 2.780168323  |
| a4           | 0.024000142  | 0.007550723  | 0.018658266  | 0.007489103  |
| b4           | 0.819512708  | 1.092840807  | 0.814226522  | 0.819524529  |
| c4           | -1.667713707 | -0.083472353 | 1.991421806  | -2.553173805 |
| a5           | 0.033334253  | 0.007032185  | 0.011620132  | 0.004757127  |
| b5           | 0.274006506  | 1.365907611  | 1.073297617  | 1.912240698  |
| c5           | 1.767893971  | -1.149768743 | 1.127142421  | -0.426425129 |
| a6           | 0.016685646  | 0.002783012  | 0.006003581  | 0.00754316   |
| b6           | 1.912001598  | 2.185454187  | 1.391439415  | 1.092669828  |
| c6           | 3.012065231  | 1.864745081  | 0.820642167  | -1.587989418 |
| a7           | 0.019615991  | 0.002989874  | 0.004474047  | 0.006007839  |
| b7           | 1.639156435  | 1.639066754  | 2.190001786  | 1.365818192  |
| c7           | 1.155386684  | -0.333019283 | -0.097700235 | -1.211469668 |
| a8           | 0.013802895  | 0.003283093  | 0.002899785  | 0.004842168  |
| b8           | 1.365874845  | 0.819545677  | 2.729609831  | 2.185441782  |
| c8           | 2.342536346  | -0.923657293 | 1.768451379  | -0.377829513 |

![Figure 3. Global and average patterns per water agency of outdoors+indoors (left), average patterns (center), global and average patterns per water agency of indoors only (right)](https://github.com/rodrigocantu/water-demand-classification/blob/main/resources/img/figure-3.png?raw=true)

## 2. [Labeling the dataset:](https://github.com/rodrigocantu/water-demand-classification/blob/main/optimization/OutdoorIndoor.gms)
  The labeling of the dataset will be done through optimization using CPLEX through GAMS. This model uses the previous method’s patterns to stablish a parameter called the **irrigation window**. Again, this is a period of the day in which people water their yard and it varies region to region. Because of this, there is a different irrigation window for Denver, Fort Collins, Scottsdale, and San Antonio.

  For each water department:
  1. Input the unlabeled total hourly consumption.
  2. Input the total outdoors and indoors consumption.
  3. Input the total consumption (outdoors+indoors).
  4. It minimizes the sum of the error between:
    1. The sums of hourly demand for outdoors and indoors for their corresponding hours.
      1. The outdoors demands stick to the irrigation window timeframe
      2. The indoors demands can take place at any hour, 1-24.
    2. And the reported total consumption.

  This outputs two tables, one for each outdoors and indoors. They contain **partial hourly demand** figures complementary to each other. With this information, **a label from 1 to 4** is assigned to each hour depending if they are only outdoor, only indoor, both outdoor and indoor, or neither. And a **Labeled Database is generated**, which does not have the demand figures, *only the labels*. This table is then used in the classification method.

## 3. [Classification Model](https://github.com/rodrigocantu/water-demand-classification/tree/main/classification)
  This method uses the **Labeled Database** generated in the *optimization phase*. The goal is to take as an input an unclassified, unlabeled, raw hourly demand dataset for a given household and to output which hours have demands either *only outdoor, only indoor, both outdoor and indoor, or neither*.

  The classification was done using scikit-learn’s **K-nearest neighbor (KNN)** algorithm through Python 3. To do this, the number of k neighbors must be defined. However, there is no concrete nor stablished way to define k. Because of this, a rule of thumb was used, stating that k is equal to the square root of the training data set size, sqrt(n) [(Hassanat et. al 2014)](https://arxiv.org/ftp/arxiv/papers/1409/1409.0919.pdf).

  Since each water department is classified individually, **there are four different k numbers**. To corroborate the use of the rule of thumb, **the accuracy was plotted against the k number from 1 to the sqrt(n)** for each water department, shown in **figure 4**.

  As it can be seen, *as the k value increases, the accuracy decreases*. However, using a low k value increases the uncertainty of the resulting model because of the nature of the KNN algorithm. Also, using k=sqrt(n), none of the accuracies drop below 90%. Denver has the most variation because of its low number of overall samples, shown in the y-axis. Therefore, **the rule of thumb, k=sqrt(n), was used**.

![Figure 4. Accuracy vs. K value for each water department](https://github.com/rodrigocantu/water-demand-classification/blob/main/resources/img/figure-4.JPG?raw=true)

***
### Pseudocode:
```
For each water agency:
data = Labeled Dataset
X = data excluding the keycode and date identifiers
Y = the labels of data
test_size = 0.33, the proportion of the data used for testing.
k = integer(floor(sqrt(length(data)*test_size))), the k value
X_train, X_test, Y_train, Y_test = model_selection.train_test_split(X, Y, test_size=test_size)
model = KNeighborsClassifier(n_neighbors=k)
model.fit(X_train, Y_train)
predicted = model.predict(X_test)
report = classification_report(Y_test, predicted)
print(report)
```
***

![K-NN Results](https://github.com/rodrigocantu/water-demand-classification/blob/main/resources/img/knn-results.JPG?raw=true)

  As seen in the report, there is a score for the *precision, recall and f1* for each of the labels. These are ways to measure the accuracy of the model. This has to do with the concepts of true positives (TP) and true negatives (TN), and of false positives (FP) and false negatives (FN). This is how many times the model correctly or incorrectly predicts a class. **However, precision, recall and f1 measure different things**.

  For instance, let’s take the first two labels as an example. If the model heavily avoids making mistakes in predicting label 1 as label 2, then it has a high precision. Likewise, if the model heavily avoids making mistakes in predicting label 2 as label 1, then it has a high recall. Then, to not look the precision or recall metrics in isolation, the f1-score comes into play. It balances both precision and recall, so if the model is good at predicting both labels 1 and 2, the f1-score will be high.

  Then there are the macro and weighted averages. The macro average is the sum of the precisions of all classes divided by the number of classes. And the weighted average is the total number of TP of all classes divided by the total number of samples in all classes, also known as support. This means that the higher the macro and weighted averages are, the better the model is.

## Results, Discussion and Conclusion
The overall accuracy of the model is in the order of 96%. Therefore, this methodology can be **effectively** used to differentiate the unlabeled hourly demands of the subject cities of Denver, Fort Collins, Scottsdale, and San Antonio.
This represents a budget-friendly and reasonably confident method for gross water usage disaggregation.

## Further Research
To corroborate if this methodology is also reproducible to other cities with similar geography as the 4 subject cities listed above. To do this, a labeled non-differentiable hourly database of the residential water usage for the new city will be needed. Then, the unlabeled version of this database will be processed through the classification algorithm and validated against the original labeled data.

## Other Applications
This methodology can be used to reconcile other non-continuous pairs of discrete monthly data and non-differentiable hourly data. Such as:
- Online sales vs. in-person sales
- Referrals to online services
- Urban transportation data

## How to use
- Install the corresponding libraries/packages mentioned below for each method.
- Adapt the code to your specific use case by changing file directories and attributes.
- Uncomment snips as needed.

## Libraries used:
  - [NumPy](https://numpy.org/install/)
  - [Pandas](https://pandas.pydata.org/pandas-docs/stable/getting_started/install.html)
  - [scikit-learn](https://scikit-learn.org/stable/install.html)
  - [matplotlib](https://matplotlib.org/users/installing.html)
  - [IBM CPLEX Optimizer](https://www.ibm.com/analytics/cplex-optimizer) (GAMS)
  - [Curve Fitting Toolbox](https://www.mathworks.com/products/curvefitting.html) (MATLAB)
