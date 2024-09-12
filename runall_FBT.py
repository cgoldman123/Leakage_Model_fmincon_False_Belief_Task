import sys, os, re, subprocess, time

results = sys.argv[1]
subject_list_path = '/media/labs/rsmith/lab-members/cgoldman/Wellbeing/theory_of_mind/TOM_subject_IDs_prolific.csv'

if not os.path.exists(results):
    os.makedirs(results)
    print(f"Created results directory {results}")

if not os.path.exists(f"{results}/logs"):
    os.makedirs(f"{results}/logs")
    print(f"Created results-logs directory {results}/logs")



subjects = []
with open(subject_list_path) as infile:
    for line in infile:
        if 'ID' not in line:
            subjects.append(line.strip())



# first process all the data
#ssub_path = '/media/labs/rsmith/lab-members/cgoldman/Wellbeing/theory_of_mind/FBT_scripts_CMG/run_FBT_process_data.ssub'

#stdout_name = f"{results}/logs/FBT_process_data-%J.stdout"
#stderr_name = f"{results}/logs/FBT_process_data-%J.stderr"

#jobname = f'process_data_FBT_fit'
#os.system(f"sbatch -J {jobname} -o {stdout_name} -e {stderr_name} {ssub_path}")
# wait 7 minutes
#time.sleep(10*60)

ssub_path = '/media/labs/rsmith/lab-members/cgoldman/Wellbeing/theory_of_mind/FBT_scripts_CMG/run_FBT.ssub'
for subject in subjects:
    stdout_name = f"{results}/logs/{subject}-%J.stdout"
    stderr_name = f"{results}/logs/{subject}-%J.stderr"

    jobname = f'FBT-fit-{subject}'
    os.system(f"sbatch -J {jobname} -o {stdout_name} -e {stderr_name} {ssub_path} {results} {subject}")

    print(f"SUBMITTED JOB [{jobname}]")
    

    


###python3 /media/labs/rsmith/lab-members/cgoldman/Wellbeing/theory_of_mind/FBT_scripts_CMG/runall_FBT.py /media/labs/rsmith/lab-members/cgoldman/Wellbeing/theory_of_mind/prolific_model_results/prolific_fit_9-12-24