import pandas as pd
import os


def create_dataset(directory):

    # load datasets and create a list of dataframes
    studies = []  # list of dataframes of different studies

    for filename in sorted(os.listdir(directory)):
        f = os.path.join(directory, filename)
        # check if f is a file
        if os.path.isfile(f):
            df = pd.read_csv(f)
            df = delete_zero_cols(df)
            studies.append(df)

    # concatenate dataframes by their common columns by adding join='inner'
    df_full = pd.concat(studies, join='inner').iloc[:, 1:]  # delete the first unnamed column
    common_features = df_full.columns
    print("Number of common features: ", len(common_features) - 3)  # -3 because of study_name, study_condition, subject_id

    # number of healthy and IBD samples
    ibd = len(df_full.loc[df_full['study_condition'] == 'IBD'])
    healthy = len(df_full.loc[df_full['study_condition'] == 'control'])
    print("Number of controls (healthy): ", healthy)
    print("Number of IBD: ", ibd)
    return df_full


def delete_zero_cols(df):
    print("Study: ", df['study_name'][0])
    print("Shape before deleting columns with only zeros: ", df.shape)
    # delete columns with only zeros
    df = df.loc[:, (df != 0).any(axis=0)]
    print("Shape after deleting columns with only zeros: ", df.shape)
    return df


def main():
    directory = "IBD_classifier/studies"
    df = create_dataset(directory)
    print("final shape: ", df.shape)
    print(df.head(5))
    #df.to_csv("data/relative_abundance_NielsenVilaLi.csv")

main()
