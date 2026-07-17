# 實驗室分析工具與機器學習練習集 / Lab Analysis Tools and Machine Learning Exercises

本專案包含了過往在深度學習、自然語言處理上的演算法實作練習，以及用於分析蛋白質與分子動力學模擬（Molecular Dynamics Simulations）的各項客製化工具腳本。

This repository contains past algorithmic implementations in deep learning and natural language processing, as well as customized scripts for analyzing proteins and Molecular Dynamics Simulations.

## Playground
### 機器學習與神經網路練習 / Machine Learning and Neural Network

本區塊主要收錄使用 Python 開發的 Jupyter Notebook 與演算法實作，涵蓋影像辨識、自然語言翻譯以及基因序列比對等基礎練習

This section includes Jupyter Notebooks and algorithm implementations developed in Python, covering basic exercises such as image recognition, natural language translation, and gene sequence alignment:

#### `cnn.ipynb`
* **CH:** 以 TensorFlow 的 Keras 套件實作卷積神經網路（CNN），並運用 MNIST 資料集進行手寫數字辨識的基礎名詞解釋與模型訓練。
* **EN:** Implementation of Convolutional Neural Networks (CNN) using TensorFlow's Keras API, including basic terminology explanations and model training for handwritten digit recognition using the MNIST dataset.

#### `handwritten_number_recognition.ipynb`
* **CH:** 結合 Scikit-Learn 與 TensorFlow，比較支持向量機（SVM）、隨機森林（Random Forest）搭配主成份分析（PCA）降維，以及 CNN 模型在手寫數字辨識上的準確度差異。
* **EN:** Combines Scikit-Learn and TensorFlow to compare the accuracy of Support Vector Machine (SVM), Random Forest with Principal Component Analysis (PCA) for dimensionality reduction, and CNN models in handwritten digit recognition.

#### `s2s.ipynb`
* **CH:** 探討並實作 Sequence to Sequence (Seq2Seq) 架構與長短期記憶神經網路（LSTM），建立將英文翻譯為繁體中文的機器翻譯模型。
* **EN:** Explores and implements the Sequence to Sequence (Seq2Seq) architecture and Long Short-Term Memory (LSTM) networks to build a machine translation model from English to Traditional Chinese.

#### `SeqAlign.ipynb`
* **CH:** 以動態規劃（Dynamic Programming）實作整體最佳化序列比對（Global Alignment）的 Python 腳本，可讀取 FASTA 格式檔案並計算序列相似度與路徑追溯。
* **EN:** A Python script implementing global sequence alignment using dynamic programming. It reads FASTA files, calculates sequence similarity, and performs traceback.

#### `Inception_v4.ipynb`
* **CH:** 使用 TensorFlow / Keras 實作的 Inception-v4 深度神經網路架構。
* **EN:** Implementation of the Inception-v4 deep neural network architecture using TensorFlow and Keras.

#### `Principal_component_analysis.ipynb`
* **CH:** CH: 主成份分析 (PCA) 介紹與實作。本筆記本深入淺出地解釋了共變異數矩陣、矩陣對角化等數學基礎，並透過 NumPy 原始實作與 Scikit-learn 套件應用，示範如何進行降維與特徵提取，最後以「特徵臉 (Eigenfaces)」作為實際應用案例。
* **EN:** Introduction and implementation of Principal Component Analysis (PCA). This notebook explains mathematical foundations such as covariance matrices and eigendecomposition. It demonstrates dimensionality reduction and feature extraction using both raw NumPy implementation and Scikit-learn, concluding with an "Eigenfaces" application.


#### `mask_rcnn_practice.ipynb`
* **CH:** CH: 本專案基於 TensorFlow 與 OpenCV 實作 Mask R-CNN 實例分割（Instance Segmentation）模型。透過載入預訓練的 COCO 資料集權重與設定檔，對輸入影像進行物件偵測並產出像素級別的遮罩（Mask），實現物體輪廓的精確分離與視覺化。
* **EN:** An implementation of Mask R-CNN for instance segmentation using TensorFlow and OpenCV. By loading pre-trained COCO dataset weights and configuration files, the project performs object detection on input images and generates pixel-level masks, achieving precise object contour extraction and visualization.


## Toolbox
### 實驗室分析工具 / Laboratory Analysis Tools

本資料夾提供一系列用於分子動力學軌跡分析、蛋白質結構與電子傳遞特性的輔助分析工具：

This directory provides a suite of auxiliary analysis tools for molecular dynamics trajectory analysis, protein structure, and electron transfer characteristics:

#### `AutoOpt2Ant`
* **CH:** 將 Optimized 的 peptide 自行尋找旋轉角並對齊電極後，產生 alacant 外掛可用的 configure file。
* **EN:** Automatically finds rotation angles for optimized peptides, aligns them with electrodes, and generates configuration files for the alacant plugin.

#### `auto_correlation`
* **CH:** 分析分子動力學模擬的軌跡檔，計算蛋白質分子表面所有水起始的偶極矩隨著時間所產生的變化。
* **EN:** Analyzes molecular dynamics simulation trajectories to calculate the time-dependent changes in the dipole moments of all initial water molecules on the protein surface.

#### `crosscorrelation_and_contact_map`
* **CH:** 利用信號學分析的 cross-correlation 原理，計算蛋白質分子的每一個片段（residue）隨著時間的運動。藉由瞭解各個片段彼此之間的關聯性，試圖找出蛋白質自由運動或是結構轉換時的發生順序與誘導關係；另外藉由將關聯分類為接觸型與非接觸型，確認目標蛋白的運動是否存在異位效應。
* **EN:** Utilizes the cross-correlation principle from signal analysis to calculate the movement of each protein residue over time. By understanding the correlations between residues, this tool attempts to identify the sequence and inductive relationships during protein free motion or structural transitions. It also classifies correlations into contact and non-contact types to determine the presence of allosteric effects in the target protein's movement.

#### `location_classification`
* **CH:** 以 SVM 模型來學習辨識蛋白質的區域（domain），並藉此分類後續分子動力學模擬中所獲得該蛋白質的表面水分子所在位置。
* **EN:** Uses an SVM model to learn and identify protein domains, subsequently classifying the locations of surface water molecules obtained from molecular dynamics simulations.

#### `redox_potential`
* **CH:** 利用 Gaussian 09 計算氧化態與還原態的 free energy，再利用基本定義轉換為標準氧化還原電位。
* **EN:** Calculates the free energy of oxidized and reduced states using Gaussian 09, converting them into standard redox potentials using basic definitions.

#### `residence_time`
* **CH:** 分析大量指定分子的遲滯時間，並利用格點技巧將該遲滯時間建立成可視覺化的檔案。
* **EN:** Analyzes the residence time of numerous specified molecules and uses grid techniques to create visualizable files of these residence times.

#### `surface_depth`
* **CH:** 利用迴轉半徑的計算方法，分析目標蛋白質表面每個區域的孔洞深度，並以格點技巧建立成可視覺化的檔案。
* **EN:** Analyzes the cavity depth of each region on the target protein's surface using the radius of gyration calculation method, creating visualizable files using grid techniques.

#### `surface_dipole`
* **CH:** 分析目標分子的表面其各局部區域的偶極矩。
* **EN:** Analyzes the dipole moments of various local regions on the surface of the target molecule.

## 相關論文發表 / Related Publications

上述 Toolbox 中的分析工具已實際應用於下列科學文獻的研究與討論中

The analysis tools in the Toolbox mentioned above have been practically applied in the research and discussion of the following scientific publications:

1. Sheh-Yi Sheu, Yu-Cheng Liu and Dah-Yen Yang, Interfacial water effect on cooperativity and signal communication in Scapharca dimeric hemoglobin, Physical Chemistry Chemical Physics, 19, 7380-7389 (2017). (https://doi.org/10.1039/c7cp00280g)
2. Sheh-Yi Sheu, Yu-Cheng Liu, Jia-Kai Zhou, Edward W. Schlag, and Dah-Yen Yang, Surface Topography Effects of Globular Biomolecules on Hydration Water, The Journal of Physical Chemistry B, Just Accepted Manuscript (2019). (https://doi.org/10.1021/acs.jpcb.9b03734)
