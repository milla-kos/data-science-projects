# This script creates and saves the train, validation and test sets from raw data to be used
# in the classification task.

import matplotlib.pyplot as plt
import numpy as np
import tensorflow as tf
import tensorflow_datasets as tfds
from sklearn.model_selection import train_test_split
import sklearn
from PIL import Image
import os
import pandas as pd
from tifffile import imread, imwrite
from skimage.transform import resize


# define functions to import the data

def import_images(d):
    '''
    function for importing images from directory d
    '''
    n = len(os.listdir(d))
    frames = np.zeros((n,int(1376/3),int(1539/3),3))
    i = 0

    # iterate over files in directory d
    for filename in sorted(os.listdir(d)):
        f = os.path.join(d, filename)
        if os.path.isfile(f):
            im = imread(f)
            im = resize(im ,(int(1376/3),int(1539/3),3))
            imarray = np.array(im)
            frames[i] = imarray
            i = i + 1

    return frames   


def import_labels(d):
    '''
    function for importing labels from directory d
    '''
    scores = []
    for filename in sorted(os.listdir(d)):
        f = os.path.join(d, filename)
        # checking if it is a file and take files that contain the final score
        if os.path.isfile(f) and ('decision' in f):
            if os.path.getsize(f) > 0:
                file = open(f,'r')
                scores.append(int(file.read()))
                file.close()
            
    return scores

def main():
    frames_path = 'raw_data/frames/'
    labels_path = 'raw_data/atypia/'

    frames = import_images(frames_path + os.listdir(frames_path)[0])
    scores = import_labels(labels_path + os.listdir(labels_path)[0])

    for subdir in os.listdir(frames_path)[1:]:
        cur_frames = import_images(frames_path + subdir)
        frames = np.concatenate((frames, cur_frames))

    for subdir in os.listdir(labels_path)[1:]:
        cur_labels = import_labels(labels_path + subdir)
        scores = np.concatenate((scores, cur_labels))

    frames, scores = sklearn.utils.shuffle(frames, scores, random_state=0)

    # divide into train and test sets
    frames_train, frames_test, labels_train, labels_test = train_test_split(frames, scores, test_size = 0.3)

    # divide again: train set and validation set
    frames_train, frames_val, labels_train, labels_val = train_test_split(frames_train, labels_train, test_size = 0.2)

    print("Train set: ", frames_train.shape,labels_train.shape)
    print("Validation set: ", frames_val.shape,labels_val.shape)
    print("Test set: ", frames_test.shape,labels_test.shape)

    # save train, validation and test sets into a dictionary
    dictionary = {'train': (frames_train,labels_train), 'val': (frames_val,labels_val), 'test': (frames_test,labels_test)}

    # save dictionary as a file
    np.save("Aperio_dataset.npy", dictionary)

main()