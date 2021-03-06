//
//  NewTaskController.m
//  Senbei
//
//  Created by Adrian on 1/30/10.
//  Copyright (c) 2010, akosma software / Adrian Kosmaczewski
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//  1. Redistributions of source code must retain the above copyright
//  notice, this list of conditions and the following disclaimer.
//  2. Redistributions in binary form must reproduce the above copyright
//  notice, this list of conditions and the following disclaimer in the
//  documentation and/or other materials provided with the distribution.
//  3. All advertising materials mentioning features or use of this software
//  must display the following acknowledgement:
//  This product includes software developed by akosma software.
//  4. Neither the name of the akosma software nor the
//  names of its contributors may be used to endorse or promote products
//  derived from this software without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY ADRIAN KOSMACZEWSKI ''AS IS'' AND ANY
//  EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL ADRIAN KOSMACZEWSKI BE LIABLE FOR ANY
//  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//   LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "NewTaskController.h"
#import "FatFreeCRMProxy.h"
#import "NSDate+Senbei.h"
#import "Task.h"

@implementation NewTaskController

@synthesize navigationController = _navigationController;

#pragma mark -
#pragma mark Init and dealloc

- (id)init
{
    if (self = [super initWithStyle:UITableViewStyleGrouped]) 
    {
        _navigationController = [[UINavigationController alloc] initWithRootViewController:self];
        NSString *controllerTitle = NSLocalizedString(@"NEW_TASK_TITLE", @"Title of the new task screen");
        self.title = controllerTitle;

        _doneButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                     target:self
                                                                                     action:@selector(done:)];
        self.navigationItem.rightBarButtonItem = _doneButtonItem;

        UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                     target:self
                                                                                     action:@selector(close:)];
        self.navigationItem.leftBarButtonItem = cancelItem;
        [cancelItem release];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(close:) 
                                                     name:FatFreeCRMProxyDidCreateTaskNotification
                                                   object:[FatFreeCRMProxy sharedFatFreeCRMProxy]];
        
        _nameField = [[UITextField alloc] initWithFrame:CGRectMake(90.0, 12.0, 200.0, 20.0)];
        _nameField.delegate = self;
        
        _bucketField = [[UITextField alloc] initWithFrame:CGRectMake(90.0, 12.0, 200.0, 20.0)];
        _bucketField.delegate = self;
        
        _categoryField = [[UITextField alloc] initWithFrame:CGRectMake(90.0, 12.0, 200.0, 20.0)];
        _categoryField.delegate = self;
        
        NSString *path = [[NSBundle mainBundle] pathForResource:@"TaskCategories" ofType:@"plist"];
        _categories = [[NSArray alloc] initWithContentsOfFile:path];
        _selectedCategory = [[[_categories objectAtIndex:0] objectForKey:@"key"] copy];
        
        path = [[NSBundle mainBundle] pathForResource:@"TaskBuckets" ofType:@"plist"];
        _buckets = [[NSArray alloc] initWithContentsOfFile:path];
        _selectedBucket = [[[_buckets objectAtIndex:0] objectForKey:@"key"] copy];
    }
    return self;
}

- (void)dealloc 
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_navigationController release];
    [_doneButtonItem release];
    [_nameField release];
    [_bucketField release];
    [_categoryField release];
    [_selectedDate release];
    [_selectedBucket release];
    [_selectedCategory release];
    [_categories release];
    [_buckets release];
    [_datePicker release];
    [_bucketPicker release];
    [_categoryPicker release];
    [super dealloc];
}

#pragma mark -
#pragma mark Event handlers

- (void)done:(id)sender
{
    if ([_nameField.text length] > 0)
    {
        _doneButtonItem.enabled = NO;
        Task *task = [[Task alloc] init];
        task.name = _nameField.text;
        task.category = _selectedCategory;
        task.bucket = _selectedBucket;
        task.dueDate = _selectedDate;
        [[FatFreeCRMProxy sharedFatFreeCRMProxy] createTask:task];
        [task release];
    }
    else
    {
        NSString *message = NSLocalizedString(@"NEW_TASK_SPECIFY_NAME", @"Text shown when trying to create a task without name");
        NSString *ok = NSLocalizedString(@"OK", @"The 'OK' word");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:ok
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
        [_nameField becomeFirstResponder];
    }
}

- (void)close:(id)sender
{
    _doneButtonItem.enabled = NO;
    [self dismissModalViewControllerAnimated:YES];
}

- (void)dateSelected:(id)sender
{
    [_selectedDate release];
    _selectedDate = [[_datePicker date] retain];
    _bucketField.text = [_selectedDate stringWithDateFormattedWithCurrentLocale];
}

#pragma mark -
#pragma mark UIViewController methods

- (void)viewDidLoad 
{
    [super viewDidLoad];
    self.tableView.scrollEnabled = NO;
}

- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:animated];
    _nameField.text = @"";
    _doneButtonItem.enabled = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_nameField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning 
{
    [super didReceiveMemoryWarning];
}

#pragma mark -
#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static NSString *CellIdentifier = @"NewTaskCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) 
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:CellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    NSString *name = NSLocalizedString(@"NEW_TASK_NAME_FIELD", @"Title of the 'name' form field");
    NSString *due = NSLocalizedString(@"NEW_TASK_DUE_FIELD", @"Title of the 'due' form field");
    NSString *category = NSLocalizedString(@"NEW_TASK_CATEGORY_FIELD", @"Title of the 'category' form field");
    
    switch (indexPath.row) 
    {
        case 0:
            cell.textLabel.text = name;
            _nameField.text = @"";
            [cell.contentView addSubview:_nameField];
            break;

        case 1:
            cell.textLabel.text = due;
            _bucketField.text = [[_buckets objectAtIndex:0] objectForKey:@"text"];
            [cell.contentView addSubview:_bucketField];
            break;
            
        case 2:
            cell.textLabel.text = category;
            _categoryField.text = [[_categories objectAtIndex:0] objectForKey:@"text"];
            [cell.contentView addSubview:_categoryField];

        default:
            break;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    switch (indexPath.row) 
    {
        case 0:
            [_nameField becomeFirstResponder];
            break;
            
        case 1:
            [_bucketField becomeFirstResponder];
            break;
            
        case 2:
            [_categoryField becomeFirstResponder];
            break;

        default:
            break;
    }
}

#pragma mark -
#pragma mark UITextFieldDelegate methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField == _nameField)
    {
        return YES;
    }

    [_nameField resignFirstResponder];

    if (textField == _categoryField)
    {
        if (_categoryPicker == nil)
        {
            _categoryPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0.0, 264.0, 320.0, 216.0)];
            _categoryPicker.delegate = self;
            _categoryPicker.showsSelectionIndicator = YES;
            [_categoryPicker selectRow:0 inComponent:0 animated:NO];
            [self.navigationController.view addSubview:_categoryPicker];
        }
        [self.navigationController.view bringSubviewToFront:_categoryPicker];
    }
    else if (textField == _bucketField)
    {
        if (_bucketPicker == nil)
        {
            _bucketPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0.0, 264.0, 320.0, 216.0)];
            _bucketPicker.delegate = self;
            _bucketPicker.showsSelectionIndicator = YES;
            [_bucketPicker selectRow:0 inComponent:0 animated:NO];
            [self.navigationController.view addSubview:_bucketPicker];
        }
        [self.navigationController.view bringSubviewToFront:_bucketPicker];
    }
    
    return NO;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


#pragma mark -
#pragma mark UIPickerViewDataSource methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    if (pickerView == _categoryPicker)
    {
        return 1;
    }
    if (pickerView == _bucketPicker)
    {
        return 1;
    }
    return 0;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (pickerView == _categoryPicker)
    {
        return [_categories count];
    }
    if (pickerView == _bucketPicker)
    {
        return [_buckets count];
    }
    return 0;
}

#pragma mark -
#pragma mark UIPickerViewDelegate methods

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (pickerView == _categoryPicker)
    {
        return [[_categories objectAtIndex:row] objectForKey:@"text"];
    }
    if (pickerView == _bucketPicker)
    {
        return [[_buckets objectAtIndex:row] objectForKey:@"text"];
    }
    return 0;    
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (pickerView == _categoryPicker)
    {
        [_selectedCategory release];
        _selectedCategory = [[[_categories objectAtIndex:row] objectForKey:@"key"] copy];
        _categoryField.text = [[_categories objectAtIndex:row] objectForKey:@"text"];
    }
    else if (pickerView == _bucketPicker)
    {
        [_selectedBucket release];
        _selectedBucket = [[[_buckets objectAtIndex:row] objectForKey:@"key"] copy];
        _bucketField.text = [[_buckets objectAtIndex:row] objectForKey:@"text"];
        
        if ([_selectedBucket isEqualToString:@"specific_time"])
        {
            if (_datePicker == nil)
            {
                _datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0.0, 264.0, 320.0, 216.0)];
                _datePicker.datePickerMode = UIDatePickerModeDate;
                [_datePicker addTarget:self 
                                action:@selector(dateSelected:) 
                      forControlEvents:UIControlEventValueChanged];
                [self.navigationController.view addSubview:_datePicker];
            }
            [_selectedDate release];
            _selectedDate = [[_datePicker date] retain];
            _bucketField.text = [_selectedDate stringWithDateFormattedWithCurrentLocale];
            [self.navigationController.view bringSubviewToFront:_datePicker];
        }
    }
}

@end
