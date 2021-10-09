<h1>SVM for Biosensors Data</h1>
The fabrication parameters and data from cyclic voltammetry (CV) were used to construct a model that recognizes the attributes between different biosensor fabrication methods. 

<h2>Module/library used</h2>
<li>caret</li>
<li>ggplot2</li>
<li>GGally</li>
<li>dplyr</li>

<h2>Data Preprocessing</h2>
Total data = 300

Training:Testing = 80:20

Each file consists of 7 columns; 6 predictive variables (Ipc, ΔEp, cycles, scan rate, gluta, GOx), and a target variable (method) which corresponds to the four fabrication methods.For this study, the numerical variables, Ipc, ΔEp, cycles and scan rate were normalized. The categorical variables gluta and GOx were translated into binary numerical data (0=No/Before, 1=Yes/After) using a one-hot encoding technique. The data were also randomized to avoid bias.

![image](https://user-images.githubusercontent.com/76251450/136640218-37c01ba4-b48c-4a1b-bd31-a72e7cd08836.png)

<h2>Exploratory Data Analysis</h2>

![image](https://user-images.githubusercontent.com/76251450/136640686-ae90f0ba-e73d-4ea0-bd9f-3657c58f56a4.png)

<h2>Model Building</h2>
I tried three different SVM models; linear, polynomial, RBF kernels and evaluated them using accuracy. The c, d and σ hyperparameters were tuned for optimal model performance using repeated k-fold cross-validation (k = 10, repeat = 3) as a re-sampling procedure to avoid underfitting or overfitting.

![image](https://user-images.githubusercontent.com/76251450/136659464-5c67eb6a-2b5c-487d-9765-30daf83dce0d.png)

![image](https://user-images.githubusercontent.com/76251450/136659473-f0759814-e2d7-4b5d-ac98-e8cd6463c0b1.png)

![image](https://user-images.githubusercontent.com/76251450/136659491-ce4edd5c-d370-47ca-b4b1-65a2539adb50.png)


<h2>Model Performance</h2>

The RBF kernel gave the highest accuracy on the training and testing sets.

![image](https://user-images.githubusercontent.com/76251450/136639785-8599f7ba-db93-48f1-8793-a60a3bfcb433.png)
