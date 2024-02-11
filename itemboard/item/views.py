from django.contrib.auth.decorators import login_required
from django.shortcuts import render, get_object_or_404,redirect
from .forms import NewItemForm
from django.http import HttpResponse, HttpResponseNotAllowed, HttpResponseNotFound
from .models import Item

def detail(request, pk):
    item = get_object_or_404(Item, pk=pk)

    return render(request, 'item/detail.html', {
        'item': item
    })
@login_required
def new(request):
    
    if request.method == 'POST':
        form = NewItemForm(request.POST, request.FILES)

        if form.is_valid():
            form.save()
            return redirect('core:index')
    else:
        form = NewItemForm()
    return render(request, 'item/form.html', {
        'form' : form
    })

@login_required
def delete_item(request, pk):
    if request.method == 'POST':
        item = get_object_or_404(Item, pk=pk)
        item.delete() # Delete the item from the database
        return redirect('core:index') # Redirect to the index page after deletion
    else:
        item = get_object_or_404(Item, pk=pk)
        return render(request, 'item/delete.html', {
            'item': item
        })

    
