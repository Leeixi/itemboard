from django.shortcuts import render, redirect
from django.contrib.auth.decorators import login_required
from django.contrib.auth import logout
from item.models import Category, Item
from .forms import SignupForm

def index(request):
    items = Item.objects.filter(is_sold=False)[0:6]
    categories = Category.objects.all()

    return render(request, 'core/index.html', {
        "categories": categories,
        "items": items
    })

def contact(request):
    return render(request, "core/contact.html")

def signup(request):
    if request.method == 'POST':
        form = SignupForm(request.POST)

        if form.is_valid():
            form.save()

            return redirect('/login')
    else:
        form = SignupForm()
    
    return render(request, 'core/signup.html', {
        'form': form
    })
@login_required
def UserLoggedIn(request):
    if request.user.is_authenticated == True:
        username = request.user.username
    else:
        username = None
    return username

def LogOutView(request):
    username = UserLoggedIn(request)
    if username != None:
        logout(request)
        return redirect('/')